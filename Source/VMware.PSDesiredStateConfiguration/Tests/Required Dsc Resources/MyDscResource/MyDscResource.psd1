@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'MyDscResource.psm1'
	
    DscResourcesToExport = @(
    'FileResource',
    'MyTestResource'
    )
    
    # Version number of this module.
    ModuleVersion = '1.0'
    
    # ID used to uniquely identify this module
    GUID = '81624038-5e71-40f8-8905-b1a87afe22d7'
    
    # Author of this module
    Author = 'VMware'
    
    # Company or vendor of this module
    CompanyName = 'VMware'
    
    # Copyright statement for this module
    Copyright = '(c) VMware. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description = 'This module contains basic dsc resources designed for use in simple tests'
    
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'
}
