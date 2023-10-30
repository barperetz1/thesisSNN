module stdp_new(
  // Inputs
  clk,
  spk_pre,
  spk_post,
  time_step,
  weight_before,
  //Output
  weight_after
  );
  
  parameter WEIGHT_SIZE = 16;

  // Number of right shifts - larger number = smaller learning rate
  parameter LEARNING_RATE = 4;

  // Module Inputs
  input clk;
  input spk_pre;
  input spk_post;
  input [7:0] time_step;
  input[WEIGHT_SIZE-1:0] weight_before;

  // Module outputs
  output reg [WEIGHT_SIZE-1:0] weight_after;

  // Intermediate Wires and registers for combinational and control logic
  reg pre_in;
  reg post_out;
  reg [7:0] time_step_post;
  reg [7:0] time_step_pre;
  wire [7:0] time_step_diff;

  // Compute the difference in time between pre and post synaptic spikes
  assign time_step_diff = time_step_post - time_step_pre;

  always @(posedge clk) begin
    // Record time of post synaptic spike and note that post synaptic spike has been recorded
    if (spk_post) begin
      time_step_post <= time_step;
      post_out <= 1;
    end

    //Record time of pre synaptic spike and note that pre synaptic spike has been recorded
    if (spk_pre) begin
      time_step_pre <= time_step;
      pre_in <= 1;
    end
    
    // Compute STDP function when a pre and post synaptic spike are recorded
    if (pre_in && post_out) begin
      pre_in <= 0;
      post_out <= 0;
      if ((time_step_pre < time_step_post) && time_step_diff < 8) begin
        // Increase weight if pre synaptic spike occurs FIRST
        weight_after <= weight_before + (weight_before >> (time_step_diff+LEARNING_RATE));
        end
      else begin
        // Decrease weight if pre synaptic spike occurs LAST
        weight_after <= weight_before + (weight_before >> (time_step_diff+LEARNING_RATE));
      end
    end
  end
endmodule

