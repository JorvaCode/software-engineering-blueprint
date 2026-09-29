# 06 — Testing

Testing is layered according to risk.

## Typical levels
- Unit tests
- Integration tests
- Contract/API tests
- End-to-end tests
- Performance tests when required
- Security tests when required

## Principles
- Tests should verify behaviour.
- Critical acceptance criteria shall have automated verification where practical.
- Tests should be deterministic and maintainable.

## Information items
### Inputs
- **Test strategy** — the levels the risk justifies, from the design.
- **Acceptance criteria** — from `01-requirements.md`, with their verification methods.
- **Implementation** — the change under test.

### Outputs
- **Test suite** — tests at the levels the strategy justifies, each mapped to the acceptance criterion or behaviour it verifies.
- **Test run result** — the outcome of the suite, with the environment, the commit and the command that produced it. A green result without those three is not evidence.
- **Criterion coverage** — which acceptance criteria have automated verification, which do not, and why. Criteria without automated verification are a named exception, not a silent gap.
- **Scenario coverage** — where `03-architecture.md` produced quality attribute scenarios, which response measures are verified and by which check. A response measure with no verifying check is a concern the project believes it has met and has not tested.
- **Defect record** — for each failure not yet fixed, the criterion affected, the severity, and the owner.

## Quality gate
The test run result for the current commit is recorded and every required check passed. Every acceptance criterion classified as critical in `01-requirements.md` has automated verification, or appears in the criterion coverage output with a stated reason. A reviewer who did not run the tests reaches the same verdict from the run result and the coverage output.
