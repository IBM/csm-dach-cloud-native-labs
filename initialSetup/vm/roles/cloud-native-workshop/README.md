# cloud-native-workshop

This role sets up a RHEL VM to work as provided workshop for the cloud-native workshop at https://github.com/IBM/csm-dach-cloud-native-labs
A number of users defined in defaults/main.yml will be set up with the necessary software to perform all hands-on labs.

## Requirements

Check: [https://github.com/IBM/csm-dach-cloud-native-labs/tree/main/initialSetup#readme](https://github.com/IBM/csm-dach-cloud-native-labs/tree/main/initialSetup#readme)

## Role Variables

Settable variables for this role that are in [defaults/main.yml](defaults/main.yml):

```yaml
number_of_users: 15
permitRootLogin: false
ssh_port: 32122
```

## Dependencies

None.

## Example Playbook

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: workstation
      roles:
         - cloud-native-workshop

## License

Apache 2.0

## Author Information

Raphael Tholl (raphael.tholl@ibm.com)
