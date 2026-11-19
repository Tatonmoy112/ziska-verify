# App role profiles for development and testing

Updated 2026-11-16. Names are examples; the app uses GET me permissions and never hard-codes a role's rights. Starting roles are ordinary backend roles after seeding.

| Example role | Permissions |
|---|---|
| Retail seller | item:lookup, history:own |
| Distributor / field inspector | item:lookup, item:bulk_lookup, history:own, incident:report |
| Supervisor | Same four rights; not normally requestable |
| Auditor | item:lookup, history:own; no everyone scope |
| Senior seller | item:lookup, item:bulk_lookup, history:own |
| Incident reporter | incident:report only |
| Trainee | Empty permissions |
| Custom bulk-only role | item:bulk_lookup; no history reads or ordinary single-lookup UI |

The office can edit these permissions. Retail membership only controls incident-picker membership; requestable controls the public access-role list. Withdrawn history:all and retail_user:add keys grant no capability. Fake role profiles live in test/fakes/roles.dart; no real credentials belong here.
