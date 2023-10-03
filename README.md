rhel_iso_kickstart
=========

This role downloads any RHEL ISO from the [Red Hat Customer Portal](https://access.redhat.com) (or really any ISO) and optionally implants a Kickstart file into a custom ISO
which is build from the downloaded ISO.

The role requires a `checksum` to be set. This checksum can be retrieved for any ISO on the Red Hat Customer Portal and can be found on the respective download page of the ISO.
To download an ISO from the Red Hat Customer Portal you need to be a Red Hat subscriber. If you don't own any subscriptions, you can make use of 
[Red Hat's Developer Subscription](https://developers.redhat.com/articles/faqs-no-cost-red-hat-enterprise-linux) which is provided at no cost by Red Hat.

Once you are able to download from the Red Hat Customer Portal, you need to create a [Red Hat API Token](https://access.redhat.com/management/api) and pass it to this role via
`api_token`.
This role is loosely based on the instructions provided by Red Hat which explain how to download ISO images via `curl` from Red Hat's Customer Portal.
These instructions can be reviewed
[here](https://access.redhat.com/documentation/de-de/red_hat_enterprise_linux/8/html/performing_a_standard_rhel_8_installation/downloading-beta-installation-images_installing-rhel)

Please note, despite the metadata at `meta/main.yml` specifying `EL` (Enterprise Linux) this role specifically works **only** for RHEL ISOs. It can probably be modified to work also
with Alma Linux or Rocky Linux, but that's a task somebody else needs to take care of, as I don't use either of those RHEL clones. The process of creating the custom ISO, however,
*should* remain the same (untested). 

Unfortunately, specifying `RHEL` as the operating system in `meta/main.yml` is not possible, as there is no distinction made between the RHEL clones and RHEL itself.

I have probably not tested every combination possible with the variables. If you find an issue, feel free to raise it or provide a pull request to fix it.

Currently this role only supports `BIOS` deployments. `UEFI` support is planned for a later release.

Provided with this role is an example Kickstart that can be used as a start to building your own. This Kickstart implements the recommended Red Hat Satellite file system layout
[1](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.12/html/installing_satellite_server_in_a_connected_network_environment/preparing_your_environment_for_installation_satellite)

Role Variables
--------------
| variable                                     | default                      | required | description                                                                    |
| :---------------------------------           | :--------------------------- | :------- | :----------------------------------------------------------------------------- |
| `api_token`                                  | unset                        | true     | API token to use to authenticate against the Red Hat Customer Portal           |
| `boot_cat_path`                              | `isolinux/boot.cat`          | false    | relative path from `temporary_work_dir_source_files_path` to the boot.cat file |
| `checksum`                                   | unset                        | true     | checksum of the ISO to download                                                |
| `cleanup_iso`                                | `false`                      | false    | whether to clean up the downloaded ISO                                         |
| `cleanup_work_dir`                           | `false`                      | false    | whether to clean up the work directory defined in `temporary_work_dir_path`    |
| `create_uefi_image`                          | `false`                      | false    | whether an UEFI image should be created                                        | 
| `custom_iso_group`                           | `root`                       | false    | group of the custom ISO to apply                                               |
| `custom_iso_mode`                            | `0600`                       | false    | owner of the custom ISO to apply                                               |
| `custom_iso_owner`                           | `root`                       | false    | chmod of the custom ISO to apply                                               |
| `dest_dir_path`                              | `{{ playbook_dir }}`         | false    | destination directory for the custom ISO                                       |
| `download_directory`                         | `{{ playbook_dir }}`         | false    | directory to store the downloaded ISO in                                       |
| `download_directory_group`                   | `root`                       | false    | group of the downloaded ISO to apply                                           |
| `download_directory_mode`                    | `0600`                       | false    | owner of the downloaded ISO to apply                                           |
| `download_directory_owner`                   | `root`                       | false    | chmod of the downloaded ISO to apply                                           |
| `download_timeout`                           | `3600`                       | false    | timeout for the download (in seconds)                                          |
| `enable_fips`                                | `false`                      | false    | whether to enable FIPS compliant cryptography                                  |
| `force_recreate_custom_iso`                  | `true`                       | false    | whether to delete the custom ISO before recreating it                          |
| `grub_cfg_path`                              | `isolinux/grub.conf`         | false    | relative path from `temporary_work_dir_source_files_path` to the grub.conf file|
| `grub_menu_selection_timeout`                | `5`                          | false    | defines how long to wait in the GRUB menu before using the default boot option |
| `implantisomd5_package_name`                 | `isomd5sum`                  | false    | package name that provides the `implantisomd5` command                         |
| `implant_md5`                                | `true`                       | false    | whether to implant an MD5 into the custom ISO that can be checked              |
| `iso_group`                                  | `root`                       | false    | group of the downloaded ISO to apply                                           |
| `isolinux_bin_path`                          | `isolinux/isolinux.bin`      | false    | relative path from `temporary_work_dir_source_files_path` to isolinux.bin file |
| `iso_mode`                                   | `0600`                       | false    | chmod of the downloaded ISO to apply                                           |
| `iso_owner`                                  | `root`                       | false    | owner of the downloaded ISO to apply                                           |
| `kickstart_path`                             | unset                        | false    | path to the kickstart file to put into the ISO                                 |
| `kickstart_root_password`                    | unset                        | false    | root password to set to in the provided kickstart                              |
| `ksvalidator_package_name`                   | `pykickstart`                | false    | name of the package that provides the command `ksvalidator`                    |
| `post_sections`                              | Check in `defaults/main.yml` | false    | List of post sections to include into the kickstart                            |
| `pxelinux_cfg_path`                          | `isolinux/isolinux.cfg`      | false    | relative path from `temporary_work_dir_source_files_path` to `isolinux.cfg`    |
| `quiet_assert`                               | `true`                       | false    | whether to quiet asserts                                                       |
| `redhat_portal_auth_url`                     | Check in `defaults/main.yml` | false    | URL to the Red Hat Portal to authenticate against                              |
| `redhat_portal_download_base_url`            | Check in `defaults/main.yml` | false    | base URL for image downloading from the Red Hat Customer Portal                |
| `temporary_mount_path`                       | `/mnt`                       | false    | path to a temporary (empty) mount point to mount the downloaded ISO to         |
| `temporary_work_dir_path`                    | `{{ playbook_dir }}/workdir` | false    | temporary directory which will be used to extract the ISO files to             |
| `temporary_work_dir_path_group`              | `root`                       | false    | group of the temporary directory to apply                                      |
| `temporary_work_dir_path_mode`               | `0755`                       | false    | chmod of the temporary directory to apply                                      |
| `temporary_work_dir_path_owner`              | `root`                       | false    | owner of the temporary directory to apply                                      |
| `temporary_work_dir_source_files_path`       | `src`                        | false    | relative path from the temp dir which will contain the files added to the ISO  |
| `temporary_work_dir_source_files_path_group` | `root`                       | false    | group of `temporary_work_dir_source_files_path` to apply                       |
| `temporary_work_dir_source_files_path_mode`  | `0755`                       | false    | chmod of `temporary_work_dir_source_files_path` to apply                       |
| `temporary_work_dir_source_files_path_owner` | `root`                       | false    | owner of `temporary_work_dir_source_files_path` to apply                       |
| `uefi_image_path`                            | `images/efiboot.img`         | false    | relative path from `temporary_work_dir_source_files_path` to the UEFI image    |
| `users`                                      | unset                        | false    | list of users to create during kickstart                                       |
| `validate_kickstart`                         | `true`                       | false    | whether to validate the provided kickstart (if provided)                       |
| `xorriso_package_name`                       | `xorriso`                    | false    | name of the package that provides the command `xorriso`                        |

## Notes

A note on `force_recreate_custom_iso`:
This variable defines whether to delete the custom ISO before recreating it. Once the custom ISO file exists, it won't be recreated, even if there are changes. 
That's because creating the ISO makes use of the command module and thus the operation is not idempotent, nor can it be checked whether the ISO should be recreated due to changes.

Note on `users` and `post_sections`:
The `users` variable can be used to deploy users during kickstart. If those users have one or more `authorized_keys` set, and the default value of `post_section` is kept
or extended, these users will have the set authorized keys deployed in `home` (also a variable for the `users` list) within the `.ssh/authorized_keys` file.

Please also note, that by default, all plays in a task that could reveal a secret value have the `no_log: true` option set to ensure no sensitive data is logged anywhere. If you
debug the playbook, please comment the `no_log: true` portion of that specific task.

## Variables `users` and `post_sections`

An extended example of only the `users` variable is illustrated down below:
```
users:
  - name: 'ansible-user'          # name of the user (required)
    gid: 2000                     # ID of the user group to create (with the same name as the user name)
    uid: 2000                     # ID of the user
    gecos: 'Ansible User'         # user's description/comment 
    create_user_group: true       # whether to create a user group (with a specific gid or without)
    groups:                       # additional groups to add the user to - these need to *exist*
      - 'wheel'
    shell: '/bin/bash'            # login shell to use
    home: '/home/remote-ansible'  # home directory
    privileged: true              # enables creation of a sudoers.d file which grants sudo privileges without a password (created by the post section template 'post__users.j2')
    lock: false                   # whether to lock the user
    password: !vault |            # the user's password. If not specified, the user account is locked by default!
          $ANSIBLE_VAULT;1.1;AES256
          [..]
    authorized_keys:              # SSH public keys to add to the user's authorized_keys file (~/.ssh/authorized_keys)
      - !vault |
          $ANSIBLE_VAULT;1.1;AES256
          [..]
      - !vault |
          $ANSIBLE_VAULT;1.1;AES256
          [..]
```
The only required option for a user is the `name`. Everything else can be mixed and matched.

An example of the `post_section` (which represents the default value):
```
post_sections:
  - name: 'User creation'        # will be used by Ansible as the 'beginning- and end marker' (see ansible.builtin.blockinfile)
    template: 'post__users.j2'   # the actual template to use

  - name: 'FIPS'
    template: 'post__fips.j2'

  - name: 'Autorelabel'
    template: 'post__autorelabel.j2'
```

It is important to understand that `%post` sections in Kickstart are evaluated top to bottom. So `User Creation` is the first `%post`-section and `Autorelabel` the last.
To extend the current default with your own `%post sections` you could specify the following in e.g. your `host_vars`:
```
post_sections: >
  {{
     _def_post_sections +
     [
       {
         'name': 'Custom %post section'
         'template: 'custom_post.j2'
       },
       {
         'name': 'Another %post section'
         'template: 'another_post.j2'
       }
     ]
  }}
```

If you want to make it more readable and don't mind duplicating the definition of `_def_post_sections`:
```
post_sections:
  - name: 'User creation'
    template: 'post__users.j2'

  - name: 'FIPS'
    template: 'post__fips.j2'

  - name: 'Autorelabel'
    template: 'post__autorelabel.j2'

  - name: 'Custom %post section'
    template: 'custom_post.j2'

  - name: 'Another %post section'
    template: 'another_post.j2'
```



Depending on the value of `implant_md5`, different menu entries are selected when booting from the ISO:
* When `implant_md5` is set to `false` the ISO will be booted without checking the MD5 (which would fail)
* When `implant_md5` is set to `true` the ISO will be booted with `rd.live.check` which will calculate the MD5 checksum of the ISO and compare it against the implanted one

Dependencies
------------

This role makes use of the [Ansible Posix collection](https://github.com/ansible-collections/ansible.posix).
Depending on whether certain actions are required, the role needs to install the following packages:
- `xorriso`: To create a custom ISO
- `isomd5sum`: To implant a MD5 checksum into a custom ISO
- `pykickstart`: To validate a given Kickstart file
Depending on whether a custom ISO is created (when implanting a kickstart), the package `xorriso` is installed.
Further, implanting a MD5 checksum into the custom ISO requires the package `isomd5sum`.

Example Playbook
----------------

### Complex example
```
---
- hosts: 'localhost'
  gather_facts: false
  roles:
    - name: 'sscheib.rhel_iso_kickstart'
  vars:
    # the checksum of a RHEL 8.8 ISO to download from the Red Hat Customer Portal
    checksum: '517abcc67ee3b7212f57e180f5d30be3e8269e7a99e127a3399b7935c7e00a09'
    download_directory: '/home/steffen/workdir'
    download_timeout: '3600'
    kickstart_path: 'example.ks'
    validate_kickstart: true
    ksvalidator_package_name: 'pykickstart'
    temporary_mount_path: '/mnt'
    temporary_work_dir_path: '/home/steffen/workdir'
    temporary_work_dir_path_owner: 'root'
    temporary_work_dir_path_group: 'root'
    temporary_work_dir_path_mode: '0755'
    temporary_work_dir_source_files_path: 'src'
    temporary_work_dir_source_files_path_owner: 'root'
    temporary_work_dir_source_files_path_group: 'root'
    temporary_work_dir_source_files_path_mode: '0755'
    dest_dir_path: '/home/steffen'
    xorriso_package_name: 'xorriso'
    isolinux_bin_path: 'isolinux/isolinux.bin'
    boot_cat_path: 'isolinux/boot.cat'
    pxelinux_cfg_path: 'isolinux/isolinux.cfg'
    grub_cfg_path: 'isolinux/grub.conf'
    download_directory_owner: 'steffen'
    download_directory_group: 'steffen'
    download_directory_mode: '0755'
    cleanup_iso: false
    cleanup_work_dir: false
    iso_owner: 'steffen'
    iso_group: 'steffen'
    iso_mode: '0600'
    custom_iso_owner: 'root'
    custom_iso_group: 'root'
    custom_iso_mode: '0755'
    force_recreate_custom_iso: true
    grub_menu_selection_timeout: 3
    implant_md5: false
    implantisomd5_package_name: 'isomd5sum'
    quiet_assert: false
    enable_fips: true
    post_sections: >
      {{
         _def_post_sections +
         [
           {
             'name': 'Custom %post section',
             'template': 'custom_post.j2'
           },
           {
             'name': 'Another %post section',
             'template': 'another_post.j2'
           }
         ]
      }}
    users:
      - name: 'ansible-user'
        gid: 2000
        uid: 2000
        gecos: 'Ansible User'
        create_user_group: true
        groups:
          - 'wheel'
        shell: '/bin/bash'
        home: '/home/remote-ansible'
        privileged: true
        lock: false
        password: !vault |
              $ANSIBLE_VAULT;1.1;AES256
              [..]
        authorized_keys:
          - !vault |
              $ANSIBLE_VAULT;1.1;AES256
              [..]

          - !vault |
              $ANSIBLE_VAULT;1.1;AES256
              [..]
    kickstart_root_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          [..]
    api_token: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          [..]
```

### Download ISO only

```
- hosts: 'localhost'
  gather_facts: false
  roles:
    - name: 'sscheib.rhel_iso_kickstart'
  vars:
    # the checksum of a RHEL 8.8 ISO to download from the Red Hat Customer Portal
    checksum: '517abcc67ee3b7212f57e180f5d30be3e8269e7a99e127a3399b7935c7e00a09'
    download_directory: '/home/steffen/workdir'
    download_timeout: '3600'
    download_directory_owner: 'steffen'
    download_directory_group: 'steffen'
    download_directory_mode: '0755'
    iso_owner: 'steffen'
    iso_group: 'steffen'
    iso_mode: '0600'
    api_token: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          [..]
```

### Download ISO and enable FIPS mode

```
- hosts: 'localhost'
  gather_facts: false
  roles:
    - name: 'sscheib.rhel_iso_kickstart'
  vars:
    # the checksum of a RHEL 8.8 ISO to download from the Red Hat Customer Portal
    checksum: '517abcc67ee3b7212f57e180f5d30be3e8269e7a99e127a3399b7935c7e00a09'
    download_directory: '/home/steffen/workdir'
    download_directory_owner: 'root'
    download_directory_group: 'root'
    download_directory_mode: '0755'
    iso_owner: 'root'
    iso_group: 'root'
    iso_mode: '0600'
    validate_kickstart: false
    temporary_mount_path: '/mnt'
    temporary_work_dir_path: '/home/steffen/workdir'
    temporary_work_dir_path_owner: 'root'
    temporary_work_dir_path_group: 'root'
    temporary_work_dir_path_mode: '0755'
    temporary_work_dir_source_files_path: 'src'
    temporary_work_dir_source_files_path_owner: 'root'
    temporary_work_dir_source_files_path_group: 'root'
    temporary_work_dir_source_files_path_mode: '0755'
    dest_dir_path: '/home/steffen/workdir'
    custom_iso_owner: 'root'
    custom_iso_group: 'root'
    custom_iso_mode: '0755'
    force_recreate_custom_iso: true
    implant_md5: true
    enable_fips: true
    api_token: !vault |
          $ANSIBLE_VAULT;1.1;AES256
```

License
-------

GPL-2.0-or-later
