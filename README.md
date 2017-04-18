 usage (THOR)
 ruby XS.rb  main --vamp tonic
 ruby XS.rb  main --vamp yin
 ruby XS.rb  main --list_drive

 ruby XS.rb  main --test_audio --vamp chroma 

for testing specific outputs  
(obtained using: vamp-simple-host --list-outputs)
 
 ruby XS.rb  main --test_audio --vamp nnls-chroma:tuning:localtuning


 //////////

 Docs

 ##Key Detector
 - Identifier:         qm-vamp-plugins:qm-keydetector
 - Plugin Version:     4
 - Vamp API Version:   2
 - Maker:              "Queen Mary, University of London"
 - Copyright:          "Plugin by Katy Noland and Christian Landone.  Copyright (c) 2006-2009 QMUL - All Rights Reserved"
 - Description:        "Estimate the key of the music"
 - Input Domain:       Time Domain
 - Default Step Size:  32768
 - Default Block Size: 32768
 - Minimum Channels:   1
 - Maximum Channels:   1

Parameter 1: "Tuning Frequency"
 - Identifier:         tuning
 - Description:        "Frequency of concert A"
 - Unit:               Hz
 - Range:              420 -> 460
 - Default:            440

Parameter 2: "Window Length"
 - Identifier:         length
 - Description:        "Number of chroma analysis frames per key estimation"
 - Unit:               chroma frames
 - Range:              1 -> 30
 - Default:            10
 - Quantize Step:      1

Output 1: "Tonic Pitch"
 - Identifier:         tonic
 - Description:        "Tonic of the estimated key (from C = 1 to B = 12)"
 - Default Bin Count:  1
 - Default Extents:    1 -> 12
 - Quantize Step:      1
 - Sample Type:        Variable Sample Rate
 - Default Rate:       1.46484
 - Has Duration:       No

Output 2: "Key Mode"
 - Identifier:         mode
 - Description:        "Major or minor mode of the estimated key (major = 0, minor = 1)"
 - Default Bin Count:  1
 - Default Extents:    0 -> 1
 - Quantize Step:      1
 - Sample Type:        Variable Sample Rate
 - Default Rate:       1.46484
 - Has Duration:       No

Output 3: "Key"
 - Identifier:         key
 - Description:        "Estimated key (from C major = 1 to B major = 12 and C minor = 13 to B minor = 24)"
 - Default Bin Count:  1
 - Default Extents:    1 -> 24
 - Quantize Step:      1
 - Sample Type:        Variable Sample Rate
 - Default Rate:       1.46484
 - Has Duration:       No

Output 4: "Key Strength Plot"
 - Identifier:         keystrength
 - Description:        "Correlation of the chroma vector with stored key profile for each major and minor key"
 - Default Bin Count:  25
 - Bin Names:          "F# / Gb major", "B major", "E major", "A major", "D major", "G major", "C major", "F major", "Bb major", "Eb major", "Ab major", "Db major", " ", "Eb / D# minor", "G# minor", "C# minor", "F# minor", "B minor", "E minor", "A minor", "D minor", "G minor", "C minor", "F minor", "Bb minor"
 - Sample Type:        One Sample Per Step
 - Has Duration:       No