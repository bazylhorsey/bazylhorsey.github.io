module PhantomZone exposing (Model, Msg, date, dateLabel, init, slug, title, update, view)

{-| "A Phantom Zone for AI": how to boot an air-gapped GPU node so the model
and the customer's data never touch memory until the machine proves what it is.

The prose is data, the same way the essay is. The one figure is interactive:
pick something to tamper with and the boot chain shows where it gets caught.
All of its state is one Maybe.

-}

import Jorn.Attribute as Attr
import Jorn.Element as Element exposing (Element)
import Jorn.Element.Html as Html
import Jorn.Event as Events


title : String
title =
    "A Phantom Zone for AI"


slug : String
slug =
    "/writing/phantom-zone-for-ai/"


date : String
date =
    "2026-10-19"


dateLabel : String
dateLabel =
    "2026.10"



-- MODEL


{-| The one thing the reader tampered with, if any. -}
type Tamper
    = SecureBootOff
    | Reflash
    | OldKernel
    | HostDriver
    | MissingHook
    | SwappedLater
    | RootReads


type alias Model =
    { tamper : Maybe Tamper }


init : Model
init =
    { tamper = Nothing }


type Msg
    = Pick (Maybe Tamper)


update : Msg -> Model -> Model
update msg model =
    case msg of
        Pick tamper ->
            { model | tamper = tamper }



-- CONTENT


type Block
    = P String
    | Quote String
    | Steps (List ( String, String ))
    | Bullets (List ( String, String ))
    | Chain


sections : List ( String, List Block )
sections =
    [ ( "The question"
      , [ P "I got asked this recently, and I haven't stopped thinking about it."
        , P "You're bringing up a brand new bare-metal GPU server for a customer with serious compliance requirements. It's air-gapped. You provision it out of band over Redfish and boot it over PXE. Design the boot so the TPM 2.0 measurements, your custom eBPF network hooks and the GPUs' VFIO bindings are all verified and active before any model runtime or customer data touches memory."
        , P "Each piece is easy to talk about on its own. The hard part is the order, and proving the order happened. Here's how I'd build it."
        ]
      )
    , ( "Phantoms can watch. They can't touch."
      , [ P "In the Superman comics, the Phantom Zone is where Krypton sent its worst criminals. Prisoners like General Zod could see everything going on outside. They just couldn't touch any of it."
        , P "That's the state I want a fresh node in. It can power on, get an address, pull its boot image and talk to the one server that checks it. It can't touch anything that matters, because everything that matters is encrypted and it doesn't have the key. It stays a phantom until it proves it shouldn't be one."
        , P "Once it does, the zone flips around. The model runs inside a zone of its own: GPUs fenced off, network shut except for what you allowed. It can see its inputs. It can't reach out."
        , P "Most answers to this question are about ordering. Load this, then that, then start the runtime. Order matters, but it isn't security. Anything running as root can start whatever it wants, in whatever order it likes. What it can't do is decrypt data it doesn't have a key for."
        , P "So the whole design hangs on one rule. The key to the model and the customer's data only comes out after the node proves it booted exactly what you expected, with the network hooks and the GPU bindings live."
        , Quote "Boot order keeps honest software in line. Key release keeps everything else out."
        ]
      )
    , ( "What the TPM actually does"
      , [ P "The TPM gets oversold, so it's worth a minute."
        , P "It doesn't stop anything from running. Secure Boot is the bouncer: firmware refuses to run code that isn't signed by a key you trust. The TPM is the camera over the door. Each stage of the boot hashes the next stage before handing it control, and adds that hash to a register called a PCR. You can't write a PCR. You can only extend it: the new value is a hash of the old value plus the new measurement. Change anything in the chain and that register comes out different, and nothing later in the boot can put it back. About the only thing a TPM will flat out refuse is handing back a secret sealed to PCR values that no longer match."
        , P "The firmware and the OS also keep an event log of everything they measured. When asked, the TPM signs the current PCR values, plus a fresh nonce so the answer can't be replayed, with a key that never leaves the chip. That signed bundle is a quote. A verifier replays the log and checks that it adds up to the quoted values. If it does, nobody edited the log. Your policy decides whether it's good news."
        , P "You want both. Secure Boot stops unsigned code. It does nothing about an old kernel you signed last year with a known hole in it, unless you remembered to revoke it. The measurements catch it either way."
        ]
      )
    , ( "The boot, step by step"
      , [ P "The whole chain is below. Pick something to tamper with and watch where it gets caught."
        , Chain
        , Steps
            [ ( "Prep it before it powers on."
              , "The BMC lives on its own management network, never the data network. Over Redfish you turn on the TPM, Secure Boot, the IOMMU and pre-boot DMA protection, enroll your own Secure Boot keys where the BMC supports it, and set a one-time network boot. When the box arrives, record its TPM's endorsement key certificate and enroll it with your attestation server. That certificate is how you'll know later that you're talking to this chip, and not something pretending to be it."
              )
            , ( "Let the firmware measure itself."
              , "Firmware measures its own code into PCR 0, its configuration into PCR 1, and any option ROMs it runs, like the network card's PXE ROM, into PCR 2. Secure Boot's state and keys go into PCR 7. Something measuring itself could just lie, which is why you want Intel Boot Guard or AMD Platform Secure Boot. With either, the processor checks the first block of firmware before running it, so a reflashed image doesn't get to vouch for itself."
              )
            , ( "Boot one signed file."
              , "PXE and TFTP don't authenticate anything, so don't trust the wire. Trust the signature. Boot a unified kernel image: kernel, initramfs and command line in one file, signed with your key. The firmware measures the whole file into PCR 4, and the stub inside it measures each piece into PCR 11. With Secure Boot on, the stub ignores any command line handed to it by whatever loaded it, so nobody slips `iommu=off` in over the network. Anything it does add, like a signed add-on, lands in PCR 12. The baked-in command line turns the IOMMU on with passthrough off, keeps the host's GPU drivers from loading, and turns on kernel lockdown, IMA and the BPF LSM."
              )
            , ( "Make the initramfs the gate."
              , "It's small and it has one job: put the box in a safe shape and prove it. Load nftables with a default drop, open only to the attestation server. Bind every GPU to `vfio-pci` before any host driver can grab it. Load the eBPF programs, attach them and pin them, so they stay attached after the loader exits. Then read back what the kernel says is live, hash it, and extend that into a PCR nothing else on this boot path uses and nothing can reset, so not 16 or 23. The unit that asks for the key `Requires=` the gate and runs `After=` it. If a check fails, the gate fails. It has to fail, not skip: a unit skipped on a condition doesn't stop the units that require it."
              )
            , ( "Prove it."
              , "The attestation server sends a fresh nonce, and the node answers with a quote over PCRs 0 through 7, 11 and 12, plus the gate's register. It's signed by an attestation key the server has already tied to that endorsement certificate. The server replays the event logs against known-good values. Keylime does all of this, it's open source, and it runs inside your own walls."
              )
            , ( "Release the key, and nothing else."
              , "Pass, and the node gets the key to the encrypted volumes that hold the model weights and the customer's data. Fail, and it gets nothing. It's up, it can reach one server, and it's holding a disk full of noise. A phantom."
              )
            , ( "Run the model in its own zone."
              , "The runtime starts last, off the volume the key unlocked, so without the key there's nothing to start. It runs in a VM with the GPUs passed through over VFIO, so tenant code never touches a host GPU driver. Egress is denied by default in eBPF and nftables, so the model, or an agent built on it, has nowhere to send anything you didn't allow. If a NIC or InfiniBand card goes through to the VM for GPU traffic, the host never sees that traffic, so fence it at the switch."
              )
            , ( "Keep proving it."
              , "IMA measures every binary and kernel module into PCR 10 before it runs, and with appraisal on, a file without a valid signature doesn't run at all. The verifier keeps asking for fresh quotes. When something shows up that isn't on the list, it revokes: the key server stops answering and the rest of the fleet stops talking to that node. Give certificates and tokens short lives, so a node that can't keep proving itself loses access on its own. A disk that's already unlocked stays unlocked, though, so when you stop trusting a node, cut its power through the BMC."
              )
            ]
        ]
      )
    , ( "The gate, up close"
      , [ P "The question says verified *and* active. Those are different things, and plenty of designs only check the first one."
        , P "An eBPF object file on disk is present. A program attached to an interface is active. So the gate doesn't hash files and call it a day. It asks the kernel what's attached right now (`bpftool` lists the programs on every interface and cgroup), hashes the instructions the kernel hands back, and measures that. Zero out the map IDs first. They change every boot, and the hash shouldn't."
        , P "Same for the GPUs. The gate reads sysfs to see which driver owns each device and what else sits in its IOMMU group. The group is the real unit of isolation, and VFIO won't hand one over until every device in it is bound to a VFIO driver or has no driver at all. So check the whole group, not just the GPU."
        , P "Then it locks the door behind itself, as far as it can. A small BPF LSM program can refuse new `bpf()` calls once the gate is done. Give it an allow-list, because systemd and the VM manager load small BPF programs of their own every time they start a unit or a VM. It won't stop root from rewriting nftables, though. Root on the host is its own problem, and I'll get to it."
        , P "Two things bite people here. `iommu=pt` shows up in half the GPU passthrough guides online. It lets the devices the host keeps for itself skip the IOMMU. Fine for a gaming rig, wrong for this one. Use `iommu.passthrough=0` and `iommu.strict=1`, so a device loses access to a buffer the moment the driver lets go of it, not a little later. The other is the gap between firmware handing off and Linux setting the IOMMU back up, where a hostile device can still DMA into memory. Pre-boot DMA protection in firmware, plus `efi=disable_early_pci_dma`, closes it. Test that last one first. Some hardware doesn't like it."
        ]
      )
    , ( "Where it breaks"
      , [ P "The crypto is the easy part. The trouble is everything around it."
        , Bullets
            [ ( "Updates."
              , "PCRs change every time the firmware or the kernel does. Bind keys to literal PCR values and a routine update bricks the fleet. On the verifier, judge firmware with a policy over the event log instead of one magic number. For anything sealed on the node itself, bind to PCR 7 plus a signed policy for PCR 11, so any release you signed keeps unlocking. Watch the flip side: an old release still carries a valid old signature. Keep a version check on the verifier, or look at `systemd-pcrlock`, which tells the TPM exactly which versions are allowed."
              )
            , ( "Your own keys."
              , "Enroll only your keys and PXE stops working, because the network card's boot ROM is usually signed by Microsoft's third-party UEFI CA. Keep that CA and you trust everything else it ever signed. Or enroll the hash of each option ROM you actually run. Either way, keep the revocation list current."
              )
            , ( "The air gap itself."
              , "Everything that normally phones home can't. There's no public NTP, so bring a time source you trust, like a GPS clock, or certificate checks drift into nonsense. The TPM makers' CA certificates have to be inside before the first box shows up. Some firmware TPMs keep their endorsement certificate on the maker's server instead of the chip, so fetch those before the box goes in. NVIDIA's GPU verifier and the Intel and AMD services behind confidential VMs expect the internet for reference values and revocation. Mirror what they need inside."
              )
            , ( "The BMC."
              , "It can reflash firmware, mount virtual media and power cycle the box, and nothing in this chain measures the BMC itself. It's the softest thing in the rack. The measurements will catch a reflash or a changed setting on the host. They won't catch the BMC being owned, so keep it on its own network and keep its firmware current."
              )
            , ( "Process."
              , "An attested box run by a sloppy process is still a sloppy box. The golden values, the signing keys and the update media need custody rules as strict as the box itself."
              )
            ]
        , P "In Superman II, the Phantom Zone doesn't fail because Zod outsmarts it. It fails because Superman hurls a hydrogen bomb into space and the blast happens to crack it open. Nobody modeled the bomb. Model the bomb."
        ]
      )
    , ( "If you don't trust the host either"
      , [ P "Everything so far keeps the node honest. It doesn't protect the customer from whoever runs the host, and revocation is damage control, not time travel. If someone had root before you noticed, anything in memory was theirs to read."
        , P "If the operator is in your threat model, and for a regulated customer it often is, go one step further. Run the model in a confidential VM, on Intel TDX or AMD SEV-SNP, with the GPU in confidential computing mode, which NVIDIA's Hopper and Blackwell parts support. The VM's memory is encrypted with keys the host never sees, and the GPU produces its own attestation evidence. Now the key release checks two pieces of evidence, the CPU's and the GPU's, and the key goes into the confidential VM, never to the host. Done right, not even root on the host can read the weights."
        ]
      )
    , ( "The short version"
      , [ P "If I had thirty seconds: Secure Boot with your own keys, a signed unified kernel image, and every stage measured into the TPM. A tiny initramfs that drops every packet except attestation, binds the GPUs to `vfio-pci`, attaches the eBPF programs, then measures what's actually live. A quote to an attestation server inside the air gap. And a key that only comes out if everything matches."
        , Quote "No match, no key. The node stays a phantom."
        , P "Every system I've built has had to live somewhere I didn't control: lockers in other people's buildings, cameras on warehouse floors, someone else's power and someone else's network. This is the cleanest version of that problem I've seen. A box that has to earn trust before it touches anything that matters."
        ]
      )
    ]


sources : List ( String, String )
sources =
    [ ( "UAPI Group, Linux TPM PCR Registry", "https://uapi-group.org/specifications/specs/linux_tpm_pcr_registry/" )
    , ( "UAPI Group, Unified Kernel Image specification", "https://uapi-group.org/specifications/specs/unified_kernel_image" )
    , ( "systemd-stub(7): the command line under Secure Boot, PCR 11 and PCR 12", "https://man7.org/linux/man-pages/man7/sd-stub.7.html" )
    , ( "systemd-cryptenroll(1): signed PCR policies and which PCRs to bind", "https://man7.org/linux/man-pages/man1/systemd-cryptenroll.1.html" )
    , ( "systemd-pcrlock(8): a TPM policy that names the versions allowed to unlock", "https://man7.org/linux/man-pages/man8/systemd-pcrlock.8.html" )
    , ( "systemd.unit(5): a failed condition doesn't fail the units that require it", "https://man7.org/linux/man-pages/man5/systemd.unit.5.html" )
    , ( "Keylime, design overview", "https://keylime.readthedocs.io/en/stable/design/overview.html" )
    , ( "Linux kernel documentation, VFIO", "https://kernel.org/doc/html/latest/driver-api/vfio.html" )
    , ( "Linux kernel documentation, LSM BPF programs", "https://docs.kernel.org/6.13/bpf/prog_lsm.html" )
    , ( "Linux kernel parameters, including iommu.passthrough and iommu.strict", "https://docs.kernel.org/admin-guide/kernel-parameters.html" )
    , ( "The patch that added efi=disable_early_pci_dma", "https://lkml.iu.edu/hypermail/linux/kernel/2001.0/01854.html" )
    , ( "DMTF, Redfish release 2020.1 overview (Secure Boot databases)", "https://www.dmtf.org/sites/default/files/Redfish_Release_2020.1_Overview.pdf" )
    , ( "NVIDIA, Hopper single GPU attestation example", "https://docs.nvidia.com/attestation/quick-start-guide/latest/attestation-examples/hopper_single_gpu.html" )
    , ( "The Phantom Zone", "https://en.wikipedia.org/wiki/Phantom_Zone" )
    , ( "Superman II (1980)", "https://en.wikipedia.org/wiki/Superman_II" )
    ]



-- THE CHAIN
-- The figure: the boot in order, and what one tampered step does to it.


type Stage
    = Prep
    | Firmware
    | SecureBoot
    | Kernel
    | Gate
    | Quoted
    | Key
    | Runtime
    | Watch


stages : List Stage
stages =
    [ Prep, Firmware, SecureBoot, Kernel, Gate, Quoted, Key, Runtime, Watch ]


type alias StageInfo =
    { name : String
    , does : String
    , mark : String
    }


info : Stage -> StageInfo
info stage =
    case stage of
        Prep ->
            StageInfo "Redfish prep" "Firmware settings, your Secure Boot keys, a one-time network boot." "out of band"

        Firmware ->
            StageInfo "Firmware" "Measures its own code, its settings and the option ROMs it runs." "PCR 0, 1, 2"

        SecureBoot ->
            StageInfo "Secure Boot" "Runs only code signed with your keys." "PCR 7"

        Kernel ->
            StageInfo "Signed UKI" "Kernel, initramfs and command line in one signed file, over PXE." "PCR 4, 11"

        Gate ->
            StageInfo "The gate" "Traffic dropped, GPUs bound to VFIO, eBPF attached and pinned, live state measured." "gate PCR"

        Quoted ->
            StageInfo "Quote" "The TPM signs the PCRs and a nonce. The verifier replays the logs." "AK signed"

        Key ->
            StageInfo "Key release" "The key to the volumes holding the weights and the data." "or nothing"

        Runtime ->
            StageInfo "Model runtime" "A VM with the GPUs passed through. Egress denied." "starts last"

        Watch ->
            StageInfo "Keep proving it" "IMA measures and appraises every binary. Fresh quotes. Revoke on change." "PCR 10"


{-| How a stage ends up, given what was tampered with. -}
type Outcome
    = Fine String
    | Hit String
    | Caught String
    | Never String


outcome : Maybe Tamper -> Stage -> Outcome
outcome tamper stage =
    case tamper of
        Nothing ->
            Fine (clean stage)

        Just SecureBootOff ->
            caughtAtQuote stage SecureBoot "off, and PCR 7 records it" "PCR 7 doesn't match"

        Just Reflash ->
            caughtAtQuote stage Firmware "new image, PCR 0 changes" "PCR 0 doesn't match"

        Just OldKernel ->
            if stage == SecureBoot then
                Fine "lets it through, it's signed"

            else
                caughtAtQuote stage Kernel "signed, but old: PCR 4 and 11 change" "PCR 4 and 11 are last year's"

        Just HostDriver ->
            caughtAtGate stage "fails: a GPU is on the host driver"

        Just MissingHook ->
            caughtAtGate stage "fails: an eBPF hook isn't attached"

        Just SwappedLater ->
            case stage of
                Key ->
                    Fine "released, then revoked"

                Runtime ->
                    Hit "a swapped binary tries to run"

                Watch ->
                    Caught "IMA blocks it, PCR 10 records it"

                _ ->
                    Fine (clean stage)

        Just RootReads ->
            -- The one that gets through: nothing new loads, so nothing changes.
            case stage of
                Runtime ->
                    Hit "root reads the VM's memory"

                Watch ->
                    Fine "sees nothing: no file changed"

                _ ->
                    Fine (clean stage)


{-| What every stage says when nothing was touched. -}
clean : Stage -> String
clean stage =
    case stage of
        Prep ->
            "done"

        Firmware ->
            "measured"

        SecureBoot ->
            "on"

        Kernel ->
            "measured"

        Gate ->
            "passed"

        Quoted ->
            "matches"

        Key ->
            "released"

        Runtime ->
            "running"

        Watch ->
            "watching"


{-| The tampering lands on `hit`, everything boots on top of it, and the quote
is where it gets caught. Nothing after the quote happens.
-}
caughtAtQuote : Stage -> Stage -> String -> String -> Outcome
caughtAtQuote stage hit what why =
    if stage == hit then
        Hit what

    else
        case stage of
            Quoted ->
                Caught why

            Key ->
                Never "withheld"

            Runtime ->
                Never "never starts"

            Watch ->
                Never "nothing to watch"

            _ ->
                Fine (clean stage)


{-| The gate checks the kernel's own view and fails before anything asks for
a key.
-}
caughtAtGate : Stage -> String -> Outcome
caughtAtGate stage what =
    case stage of
        Gate ->
            Caught what

        Quoted ->
            Never "never runs"

        Key ->
            Never "never asked for"

        Runtime ->
            Never "never starts"

        Watch ->
            Never "nothing to watch"

        _ ->
            Fine (clean stage)


readout : Maybe Tamper -> String
readout tamper =
    case tamper of
        Nothing ->
            "Nothing tampered with. Every measurement matches, the verifier releases the key, and the model starts inside its own zone."

        Just SecureBootOff ->
            "Someone switched Secure Boot off from the BMC. The box still boots, but PCR 7 records it before the kernel ever loads. The quote doesn't match, so no key, and the disks stay locked."

        Just Reflash ->
            "Someone reflashed the firmware through the BMC. With Boot Guard or Platform Secure Boot, the processor checks the first firmware block before it runs, so the new image can't lie about itself. PCR 0 changes, and the verifier says no."

        Just OldKernel ->
            "Someone put last year's kernel image on the boot server. It's signed with your key, and unless you revoked it, Secure Boot lets it through. But PCR 4 and PCR 11 don't match the current release, so the verifier says no. Secure Boot checks who signed it. The measurements check what it is."

        Just HostDriver ->
            "One GPU came up on the host driver instead of vfio-pci. The gate reads the kernel's view, sees it, and fails before anything asks for a key. Edit the gate to skip that check and the signed image changes, so Secure Boot or PCR 11 gives it away."

        Just MissingHook ->
            "One eBPF program didn't attach. A file on disk doesn't count. The gate reads what the kernel actually has attached, comes up short, and fails. The node never even asks for a key."

        Just SwappedLater ->
            "Hours in, someone swaps a binary on a running node. With IMA appraisal on, an unsigned file won't run, and its hash still lands in PCR 10. The next quote shows a hash nobody approved, and the verifier revokes. Revoking stops new keys. It can't take back the one already in memory, so cut the node's power from the BMC."

        Just RootReads ->
            "Someone with root on the host reads the VM's memory with tools that were already approved. Nothing new loaded, so every measurement still matches. Nothing in this chain catches it. That's what the confidential VM further down is for."


choices : List ( Maybe Tamper, String )
choices =
    [ ( Nothing, "nothing" )
    , ( Just SecureBootOff, "secure boot off" )
    , ( Just Reflash, "firmware reflashed" )
    , ( Just OldKernel, "old signed kernel" )
    , ( Just HostDriver, "GPU on host driver" )
    , ( Just MissingHook, "eBPF hook missing" )
    , ( Just SwappedLater, "binary swapped later" )
    , ( Just RootReads, "root reads memory" )
    ]



-- VIEW


view : Model -> Element Msg
view model =
    Html.article
        [ Attr.class "essay zone wrap" ]
        [ Html.header [ Attr.class "essay-head" ]
            [ Html.p [ Attr.class "eyebrow" ]
                [ Element.text ("deep dive / " ++ dateLabel) ]
            , Html.h1 [ Attr.class "essay-title" ] [ Element.text title ]
            , Html.p [ Attr.class "study-dek" ]
                [ Element.text "How to boot an air-gapped GPU node so the model and the customer's data never touch memory until the machine proves what it is." ]
            , Html.p [ Attr.class "essay-byline" ]
                [ Html.b [] [ Element.text "Bazyl Horsey" ]
                , Html.span [] [ Element.text "Chicago, IL" ]
                ]
            ]
        , Html.div [ Attr.class "essay-body" ]
            (List.concatMap (viewSection model) sections
                ++ [ Html.h2 [] [ Element.text "Sources" ]
                   , Html.ol [ Attr.class "study-sources" ] (List.map source sources)
                   ]
            )
        , Html.footer [ Attr.class "essay-end" ]
            [ Html.a [ Attr.class "btn", Attr.href "/" ] [ Element.text "Back to the portfolio" ]
            , Html.a [ Attr.class "btn", Attr.href "mailto:bhorsey16@gmail.com" ]
                [ Element.text "bhorsey16@gmail.com" ]
            ]
        ]


viewSection : Model -> ( String, List Block ) -> List (Element Msg)
viewSection model ( heading, blocks ) =
    Html.h2 [] [ Element.text heading ] :: List.map (viewBlock model) blocks


viewBlock : Model -> Block -> Element Msg
viewBlock model block =
    case block of
        P text ->
            Html.p [] (inline text)

        Quote text ->
            Html.blockquote [ Attr.class "essay-quote" ]
                [ Html.p [] [ Element.text text ] ]

        Steps items ->
            Html.ol [ Attr.class "essay-steps" ] (List.map leadItem items)

        Bullets items ->
            Html.ul [ Attr.class "essay-bullets" ] (List.map leadItem items)

        Chain ->
            chain model


chain : Model -> Element Msg
chain model =
    Html.figure [ Attr.class "study-fig zone-fig" ]
        [ Html.figcaption [ Attr.class "study-fig-cap" ]
            [ Element.text "fig 01 / tamper with one thing, see where it gets caught" ]
        , Html.div [ Attr.class "filters study-filters" ]
            (List.map (choiceButton model.tamper) choices)

        -- The verdict sits right under the buttons, so on a phone it's on
        -- screen the moment you tap. The chain below shows why.
        , Html.p [ Attr.class "study-readout zone-readout", Attr.attribute "aria-live" "polite" ]
            [ Element.text (readout model.tamper) ]
        , Html.ol [ Attr.class "zone-chain" ]
            (List.indexedMap (stageRow model.tamper) stages)
        , Html.p [ Attr.class "study-caption" ]
            [ Element.text "The boot, in order, with where each step is measured. The step that goes wrong turns orange, the step that catches it gets a bar, and nothing after the catch happens." ]
        ]


choiceButton : Maybe Tamper -> ( Maybe Tamper, String ) -> Element Msg
choiceButton current ( tamper, label ) =
    Html.button
        [ Attr.class
            (if tamper == current then
                "filter is-on"

             else
                "filter"
            )
        , Attr.type_ "button"
        , Attr.attribute "aria-pressed"
            (if tamper == current then
                "true"

             else
                "false"
            )
        , Events.onClick (Pick tamper)
        ]
        [ Element.text label ]


stageRow : Maybe Tamper -> Int -> Stage -> Element msg
stageRow tamper i stage =
    let
        s =
            info stage

        ( state, note ) =
            case outcome tamper stage of
                Fine text ->
                    ( "is-ok", text )

                Hit text ->
                    ( "is-hit", text )

                Caught text ->
                    ( "is-caught", text )

                Never text ->
                    ( "is-off", text )
    in
    Html.li [ Attr.class ("zone-step " ++ state) ]
        [ Html.span [ Attr.class "zone-n" ] [ Element.text (twoDigits (i + 1)) ]
        , Html.span [ Attr.class "zone-main" ]
            [ Html.b [ Attr.class "zone-k" ] [ Element.text s.name ]
            , Html.span [ Attr.class "zone-d" ] [ Element.text s.does ]
            ]
        , Html.span [ Attr.class "zone-mark" ] [ Element.text s.mark ]
        , Html.span [ Attr.class "zone-state" ] [ Element.text note ]
        ]


twoDigits : Int -> String
twoDigits n =
    String.padLeft 2 '0' (String.fromInt n)


{-| Words in backticks are code, words in asterisks are italic. Splitting on
the marker puts every odd piece inside it.
-}
inline : String -> List (Element msg)
inline text =
    String.split "`" text
        |> List.indexedMap Tuple.pair
        |> List.filter (\( _, piece ) -> piece /= "")
        |> List.concatMap
            (\( i, piece ) ->
                if modBy 2 i == 1 then
                    [ Html.code [] [ Element.text piece ] ]

                else
                    italics piece
            )


italics : String -> List (Element msg)
italics text =
    String.split "*" text
        |> List.indexedMap Tuple.pair
        |> List.filter (\( _, piece ) -> piece /= "")
        |> List.map
            (\( i, piece ) ->
                if modBy 2 i == 1 then
                    Html.em [] [ Element.text piece ]

                else
                    Element.text piece
            )


leadItem : ( String, String ) -> Element msg
leadItem ( lead, rest ) =
    -- One span, so the numbered list's grid sees a single content cell.
    Html.li []
        [ Html.span [] (Html.strong [] [ Element.text lead ] :: Element.text " " :: inline rest) ]


source : ( String, String ) -> Element msg
source ( label, href ) =
    Html.li [] [ Html.a [ Attr.href href ] [ Element.text label ] ]
