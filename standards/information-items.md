# Information Items

Every phase produces something, and that something has to be identifiable and checkable by someone who was not there. This standard defines what a phase shall declare, and what makes a declaration sufficient.

## Source and scope

**ISO/IEC/IEEE 15289:2019** (*Content of life-cycle information items*) is the standard this follows. It specifies the purpose and content of life-cycle information items, and classifies documents into generic types: **description, plan, policy, procedure, report, request, specification**. This blueprint uses its distinction between declaring an item and specifying its content.

The same separation appears in ISO/IEC/IEEE 12207:2017, which defines processes by their purpose, outcomes, activities and tasks, and explicitly does not detail the information items in name, format, content and support — that work belongs to 15289. The reason is worth keeping in mind: a process and its paperwork are specified separately, so a change to one is not automatically a change to the other.

This standard applies to phases `01` … `14`. Phase `00` is a statement of principles, not a process, and declares no information items.

## What a phase declares

Each phase document in `blueprint/` carries an `## Information items` section with two subsections:

- `### Inputs` — the information items the phase consumes, each with its origin.
- `### Outputs` — the information items the phase produces, each stating what it shall contain.

An output that does not state its content is a name, not an information item. `02-analysis.md` originally said "an analysis decision", which told a reader what to call the thing and nothing about what to put in it.

## What makes content sufficient

An output's stated content is sufficient when a reader who was not present can answer three questions without asking the author:

1. **What was decided or built, and on what basis?** The artifact states the decision or the behaviour, not merely that one occurred.
2. **How would a third party check it?** There is a named criterion, and where the claim is quantitative, a threshold.
3. **What was deliberately left out?** Scope exclusions, skipped checks and residual risks are recorded. An artifact that lists only successes cannot be reviewed.

## Retention

An information item is retained where the project keeps its other engineering records, and for as long as the thing it describes is in use. The blueprint does not prescribe a storage technology, because that is a project decision, with two constraints:

- An output that another phase consumes shall be discoverable by that phase. A decision recorded where the next phase does not look is not retained, it is lost.
- A decision record that is later reversed is superseded, not edited. The history is the evidence.

## Versioning

An information item carries an identity, not a filename. A change that alters what an item asserts is a new version of that item, and the previous version stays addressable.

The project decides its own version scheme. Where it adopts Semantic Versioning, an information item that is a **description** or a **specification** — in the 15289 sense — follows it, and a change to a public contract is a major change. This is a recommendation, not an obligation: the obligation is that the version is stated and that history is preserved.

## Known limitation

This standard makes each phase's outputs checkable against the phase's own text. It does not yet make the phases checkable against each other: a change to a requirement has no enforced link to the design and the tests that implement it, and to the release that shipped it. That is traceability, it is a separate concern, and it is not solved here.
