<#
 # WMI WBEM_SECURITY_FLAGS
 # https://docs.microsoft.com/en-us/windows/win32/api/wbemcli/ne-wbemcli-wbem_security_flags
 # https://docs.microsoft.com/en-us/windows/win32/secauthz/standard-access-rights
 #>
 
 [hashtable]$SecurityFlags = @{
    'WBEM_Enable'            = 1;
    'WBEM_Method_Execute'    = 2;
    'WBEM_Full_Write_Rep'    = 4;
    'WBEM_Partial_Write_Rep' = 8;
    'WBEM_Write_Provider'    = 0x10;
    'WBEM_Remote_Access'     = 0x20;
    'WBEM_Right_Subscribe'   = 0x40;
    'WBEM_Right_Publish'     = 0x80;
    'Read_Control'           = 0x20000;
    'Write_DAC'              = 0x40000;
};

[hashtable]$SecurityDescription = @{
    1       = 'Enables the account and grants the user read permissions. This is a default access right for all users and corresponds to the Enable Account permission on the Security tab of the WMI Control. For more information, see Setting Namespace Security with the WMI Control.';
    2       = 'Allows the execution of methods. Providers can perform additional access checks. This is a default access right for all users and corresponds to the Execute Methods permission on the Security tab of the WMI Control.';
    4       =  'Allows a user account to write to classes in the WMI repository as well as instances. A user cannot write to system classes. Only members of the Administrators group have this permission. WBEM_FULL_WRITE_REP corresponds to the Full Write permission on the Security tab of the WMI Control.';
    8       = 'Allows you to write data to instances only, not classes. A user cannot write classes to the WMI repository. Only members of the Administrators group have this right. WBEM_PARTIAL_WRITE_REP corresponds to the Partial Write permission on the Security tab of the WMI Control.';
    0x10    = 'Allows writing classes and instances to providers. Note that providers can do additional access checks when impersonating a user. This is a default access right for all users and corresponds to the Provider Write permission on the Security tab of the WMI Control.';
    0x20    = 'Allows a user account to remotely perform any operations allowed by the permissions described above. Only members of the Administrators group have this right. WBEM_REMOTE_ACCESS corresponds to the Remote Enable permission on the Security tab of the WMI Control.';
    0x40    = 'Specifies that a consumer can subscribe to the events delivered to a sink. Used in IWbemEventSink::SetSinkSecurity.';
    0x80    = 'Specifies that the account can publish events to the instance of __EventFilter that defines the event filter for a permanent consumer. Available in wbemcli.h.';
    0x20000 = 'The right to read the information in the objects security descriptor, not including the information in the system access control list (SACL).';
    0x40000 = 'The right to modify the discretionary access control list (DACL) in the objects security descriptor.';
};

[hashtable]$SecurityNames = @{
    'Enable'        = 'WBEM_Enable';
    'MethodExecute' = 'WBEM_Method_Execute';
    'FullWrite'     = 'WBEM_Full_Write_Rep';
    'PartialWrite'  = 'WBEM_Partial_Write_Rep';
    'ProviderWrite' = 'WBEM_Write_Provider';
    'RemoteAccess'  = 'WBEM_Remote_Access';
    'Subscribe'     = 'WBEM_Right_Subscribe';
    'Publish'       = 'WBEM_Right_Publish';
    'ReadSecurity'  = 'Read_Control';
    'WriteSecurity' = 'Write_DAC';
};

[hashtable]$AceFlags = @{
    'Access_Allowed'    = 0x0;
    'Access_Denied'     = 0x1;
    'Container_Inherit' = 0x2;
}

[hashtable]$IcingaWBEM = @{
    SecurityFlags       = $SecurityFlags;
    SecurityDescription = $SecurityDescription
    SecurityNames       = $SecurityNames;
    AceFlags            = $AceFlags;
}

Export-ModuleMember -Variable @( 'IcingaWBEM' );
