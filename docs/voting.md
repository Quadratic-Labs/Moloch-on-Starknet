# Voting
Voting follows a procedure in several steps to allow for maximum security. Note that since non-members do not have the privilege to submit proposals, we do not require proposals to be sponsored like in Moloch.

## Proposal Lifecycle

  1. Submission: a proposal can be submitted by any member with the right privileges. It is assumed that a member will be honest enough to not monopolise proposal throughput, facing the risk of guildkick otherwise.
  1. Voting Period: during the voting period, members can cast their votes or possibly use a veto available in rare circumstances.
  1. Grace Period: following the voting period, members are given the grace period to ragequit the DAO if they wish. This is a major safety net for members against majority dictatorship.
  1. Processing: votes are counted and if the proposal is accepted, the related actions needed to fulfill the proposal are processed.

# Proposal States

  1. submitted: The proposal is submitted and open to voting.
  1. voted: The proposal is in the grace period.
  1. accepted: The voting and grace periods have ended and the proposal was accepted. The proposal can now be processed.
  1. rejected (final): The voting and grace periods have ended and the proposal was rejected.
  1. aborted (final): The voting period was aborted, for example due to a veto.
  1. processed (final): The proposal's actions were processed successfully.
  1. failed (final): The proposal's actions failed to be processed or could not be processed. This could happen for example due to lack of funds.

## Acceptance rules
Proposals acceptance follow a simple majority rule with a quorum constraint. A proposal is accepted whenever:

  1. The majority threshold is attained, that is the proportion of votes for the proposal over the total number of votes is greater to the threshold. The required majority is configured per proposal type, but can be increased on a proposal basis by the submittor if wished.
  1. The quorum threshold is attained, that is the proportion of members voting on the proposal and not ragequitting over the total number of allowed voters is greater to the threshold. The required quorum is configured per proposal type, but can be increased on a proposal basis by the submittor if wished.
  1. No member used a veto.
