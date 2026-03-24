enum StepState { pending, running, done, failed }

class PipelineStep {
  final String label;
  final String command;
  StepState state;
  PipelineStep(this.label, this.command, {this.state = StepState.pending});
}
