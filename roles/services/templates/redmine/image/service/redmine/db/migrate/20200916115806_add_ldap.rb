class AddLdap < ActiveRecord::Migration[5.2]
  def change
    execute "INSERT INTO public.auth_sources
(type, name, host, port, account, account_password, base_dn, attr_login, attr_firstname, attr_lastname, attr_mail, onthefly_register, tls, filter, timeout, verify_peer)
VALUES('AuthSourceLdap', '{{ sonet_redmine['ldap_auth_name'] }}', '{{ sonet_redmine['ldap_host'] }}', 389, '{{ sonet_redmine['ldap_account'] }}', '{{ sonet_redmine['ldap_account_password'] }}', '{{ sonet_redmine['ldap_base_dn'] }}', '{{ sonet_redmine['ldap_attr_login'] }}', '{{ sonet_redmine['ldap_attr_firstname'] }}', '{{ sonet_redmine['ldap_attr_lastname'] }}', '{{ sonet_redmine['ldap_attr_mail'] }}', true, false, '{{ sonet_redmine['ldap_filter'] }}', NULL, false)"
  end
end
