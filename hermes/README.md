# Hermes OoO Overview
The main objective of the model is to improve memory operation efficiency by using loading information. 
This approach initiates memory loads early through the main memory controller to avoid delays from memory hierarchy traversal. 
We use the 'features' that describe these loading activities, which are then converted into a single hashed value. 
This value is multiplied by the model weights, and the result is processed through an activation function. 
The outcome helps predict and prevent potential stalls, thus enhancing system performance.

## Paper Reference
Access the detailed paper of Hermes [here](https://arxiv.org/pdf/2209.00188).

## Source Code
The complete source code for the Hermes project is available on [GitHub repository](https://github.com/CMU-SAFARI/Hermes).

## Explanation Video
Video explanation about Hermes [YouTube](https://www.youtube.com/watch?v=afGc1pWr-_Y).

## Implementation Steps
1. **Preliminary Step:**
   - Before writing in Verilog, ensure the correctness of the implementation initially in C++.

2. **Core Functionality:**
   - Extract the core functionality of the Hermes predictor from the initial implementation.

3. **Integration with Out-of-Order (OOO) Implementation:**
   - Review the features provided by our OoO implementation.
   - Update `feat_hash.cpp` and `features.h`.

4. **Model Training:**
   - Train the model using our specific dataset.

5. **Model Deployment:**
   - Save the trained model weights.
   - Determine if we load these weights into the Verilog module or consider hardcoding the weights directly.