# List of known limitations
This is is a list of known problems and limitations regarding Microsoft PowerShell Desired State Configuration and PowerShell.

## PowerShell 7.0 limitations
- Paths used for modules containing DSC resources must not have a space in them, because the path gets cut. Bug: [PowerShell repo](https://github.com/PowerShell/PowerShell/issues/13250)
- The **Get-DscResource** used in **New-VmwDscConfiguration** sometimes fails to retrieve composite dsc resources and results in an exception when using composite resources in configurations. 
- In Linux distributions Composite Resources are not discoverable due to a bug in PowerShell Core for finding DscResources directory. The resource not being discoverable leads to a ParseException when using a Configuration with it.
- In some cases in linux the dsc resources don't get imported properly and the following command needs to be run preemptively in order for the dsc resources to be imported
   ```
    Get-DscResources -Module '$modulename'
   ``` 
- **Invoke-DscResource** is currently having a severe and will potentially get fixed in PowerShell 7.2
Issue link: [PowerShell repo](https://github.com/PowerShell/PowerShell/issues/13996)
