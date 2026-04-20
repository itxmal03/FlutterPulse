enum PipelineStepState { pending, running, done, failed }

class PipelineStep {
  final String label;
  final String command;
  PipelineStepState state;
  PipelineStep(
    this.label,
    this.command, {
    this.state = PipelineStepState.pending,
  });
}
