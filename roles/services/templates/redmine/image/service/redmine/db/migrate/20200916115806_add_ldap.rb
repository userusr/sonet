class AddLdap < ActiveRecord::Migration[5.2]
  def change
    execute "INSERT INTO public.auth_sources
(type, name, host, port, account, account_password, base_dn, attr_login, attr_firstname, attr_lastname, attr_mail, onthefly_register, tls, filter, timeout, verify_peer)
VALUES('AuthSourceLdap', '{{ redmine['ldap_auth_name'] }}', '{{ redmine['ldap_host'] }}', 389, '{{ redmine['ldap_account'] }}', '{{ redmine['ldap_account_password'] }}', '{{ redmine['ldap_base_dn'] }}', '{{ redmine['ldap_attr_login'] }}', '{{ redmine['ldap_attr_firstname'] }}', '{{ redmine['ldap_attr_lastname'] }}', '{{ redmine['ldap_attr_mail'] }}', true, false, '{{ redmine['ldap_filter'] }}', NULL, false)"
  end
end
