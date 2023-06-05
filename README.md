
```
.
├── COMBINATION 🚧 
│   └── view-evtx.ps1
├── CUI 🚧
│   ├── module_cui
│   │   └── module_cui.psm1
│   └── test_cui.ps1
├── EVTX
│   ├── convert-evtx-json.ps1 : .evtx -> .json
│   ├── convert-evtx-xml.ps1  : .evtx -> .xml
│   ├── module_evtx
│   │   └── module_evtx.psm1
│   └── offline_analyze
│        ├── Client_Offline.xml     : wevtutil struct query
│        └── logAnalyzeOffline.ps1  : Analyze Local Machine Logon
├── GUI
│   └── Windows Forms
│       ├── module
│       │   └── module_dialog.psm1
│       ├── open-inputbox.ps1
│       ├── select-File.ps1
│       ├── select-Folder.ps1
│       ├── show-msgbox.ps1
│       └── test-dialog.ps1
├── SECURITY
│   ├── credential-dump
│   │   ├── Dump-lsass.ps1              : Dump lsass-memory
│   │   ├── Get-BootKey-Offline.ps1     : Get BootKey from SYSTEM File
│   │   ├── Get-NTHash-Live.ps1         : Get Local Machine`s NTHash
│   │   ├── Get-NTHash-Live-SYSTEM.ps1
│   │   ├── Get-SAM.ps1                 : Extract SAM-Database
|   |   └── Bypass-UAC.ps1              : Bypass UAC (SDCLT)
│   ├── generateNTLM.ps1
│   ├── module_sec
│   │   ├── module_credential.psm1   : test-file:module_credential.psm1
│   │   └── module_executeAdmin.psm1 : test-file:module_executeAdmin.psm1
│   ├── registry-manipulation
│   ├── security.md
│   ├── test_credential.ps1
│   └── test_executeAdmin.ps1
└── WEB 🚧
    ├── check_ip.ps1
    ├── control_edge.ps1
    ├── download_edgeDriver.ps1  : Download the appropriate msedgedriver according to the version of edge
    ├── download_url.ps1
    ├── module_web
    │   └── module_edge.psm1
    └── tempMail.ps1
```
