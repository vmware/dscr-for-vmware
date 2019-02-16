# VMHostVssTeaming

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Server** | Key | string | Name of the Server we are trying to connect to. The Server can be a vCenter or ESXi. ||
| **Name** | Key | string | Name of the VMHost to configure. ||
| **Credential** | Mandatory | PSCredential | Credentials needed for connection to the specified Server. ||
| **Ensure** | Mandatory | Ensure | Value indicating if the VSS should be Present or Absent. | Present, Absent |
| **VssName** | Mandatory | string | The name of the VSS. ||
| **CheckBeacon** | Optional | Boolean | The flag to indicate whether or not to enable this property to enable beacon probing
    as a method to validate the link status of a physical network adapter. ||
| **ActiveNic** | Optional | string[] | List of active network adapters used for load balancing. ||
| **StandbyNic** | Optional | string[] | Standby network adapters used for failover. ||
| **NotifySwitches** | Optional | Boolean | Flag to specify whether or not to notify the physical switch if a link fails. ||
| **Policy** | Optional | NicTeamingPolicy | Network adapter teaming policy. |  LoadBalance_IP, LoadBalance_SrcMAC, LoadBalance_SrcId, Failover_Explicit |
| **RollingOrder** | Optional | Boolean | The flag to indicate whether or not to use a rolling policy when restoring links. ||

## Description

The resource is used to configure the network adapter teaming policy of a Virtual Switch (VSS). The VSS needs to exist.

## Examples

### Example 1

Configures the teaming settings of the specified Virtual Switch.

````powershell
SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]
    $Name,

    [Parameter(Mandatory = $true)]
    [string]
    $Server,

    [Parameter(Mandatory = $true)]
    [string]
    $User,

    [Parameter(Mandatory = $true)]
    [string]
    $Password
)

$script:configurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

Configuration VMHostVssTeaming_Config {
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node localhost {
        $Password = $Password | ConvertTo-SecureString -AsPlainText -Force
        $Credential = New-Object System.Management.Automation.PSCredential($User, $Password)

        VMHostVssTeaming vmHostVSSTeaming {
            Name = $Name
            Server = $Server
            Credential = $Credential
            VssName = 'VSS1'
            CheckBeacon = $false
            ActiveNic = @('vmnic0','vmnic1')
            StandbyNic = @()
            NotifySwitches = $true
            Policy = [NicTeamingPolicy]::LoadBalance_SrcId
            RollingOrder = $false
            DependsOn = "[VMHostVss]VVS1"
        }
    }
}
````
