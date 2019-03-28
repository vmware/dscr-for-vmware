dsc {'vCenter-Settings':
  resource_name => 'vCenterSettings',
  module => 'VMware.vSphereDSC',
  properties => {
    'server' => '<server>',
    'credential' => {
      'dsc_type' => 'MSFT_Credential',
      'dsc_properties' => {
        'user' => '<user>',
        'password' => Sensitive('<password>')
      }
    },
    'logginglevel' => 'Warning',
    'eventmaxageenabled' => false,
    'eventmaxage' => 40,
    'taskmaxageenabled' => false,
    'taskmaxage' => 40,
    'motd' => 'Hello World from motd!',
    'issue' => 'Hello World from issue!'
  }
}
