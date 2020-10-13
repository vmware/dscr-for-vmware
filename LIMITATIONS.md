# List of known limitations
This is is a list of known problems and limitations regarding Dsc and powershell.

## Powershell Core limitations
- Paths used for modules containing DSC resources must not have a space in them, because the path gets cut. Bug: https://github.com/PowerShell/PowerShell/issues/13250
- In Linux distributions Composite Resources are not discoverable due to a bug in powershell Core for finding DscResources directory. The resource not being discoverable leads to a ParseException when using a Configuration with it.
- In some cases in linux the dsc resources don't get imported properly and the following command needs to be run preemptively in order for the dsc resources to be imported
   ```
    Get-DscResources -Module '$modulename'
   ``` 
