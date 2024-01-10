0.1.4 - 2024-01-11
==================
- Rename internal module role to service-role.
- Set input variable object property 'conditions' as optional with default value/
- Replace some duplicated ARNs with local values.

0.1.3 - 2023-11-21
==================
- Require input variable `vpc_id`.
- Rename input variable `database_min_instances` to `cluster_instance_count`.
- Update variable descriptions.

0.1.2 - 2023-11-19
==================
- Fix identifier for final snapshot of Neptune cluster.
- Require non-empty list for input variable `neptune_subnet_ids`.

0.1.1 - 2023-11-19
==================
- Remove default value of variable `neptune_subnet_ids`.
- Add AWS plugin to TFLint.

0.1.0 - 2023-11-19
==================
- Initial release of the module.
