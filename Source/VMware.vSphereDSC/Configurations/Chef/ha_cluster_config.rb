dsc_resource 'ha-cluster' do
    resource :hacluster
    property :server, '<server>'
    property :credential, ps_credential('<user>', '<password>')
    property :name, 'MyChefCluster'
    property :datacenterinventorypath, ''
    property :datacenter, 'Datacenter'
    property :ensure, 'Present'
    property :haenabled, true
    property :haadmissioncontrolenabled, true
    property :hafailoverlevel, 3
    property :haisolationresponse, 'DoNothing'
    property :harestartpriority, 'Low'
end
