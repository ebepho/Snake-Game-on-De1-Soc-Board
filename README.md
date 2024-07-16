# Snake Game on DE1-SoC FPGA Board
## Disclaimer

This final project is intended to showcase the skills and knowledge I acquired during one of my classes. It is provided for educational and informational purposes only. If you are a student, please do not use this code to complete your own assignments or projects. Doing so may violate your institution's academic integrity policies. I am not responsible for any misuse of the code, including but not limited to academic dishonesty or plagiarism. By using the code in this repository, you agree to use it responsibly and ethically.

This project utilizes VGA and PS2 adapters for display and input functionalities, respectively. These adapters are proprietary to the University of Toronto and are not included in this repository due to copyright restrictions. Interested parties are encouraged to search online for similar VGA and PS2 adapter implementations that are compatible with the DE1-SoC FPGA board.

## Overview
This project is a hardware implementation of the classic Snake game, crafted in SystemVerilog for the DE1-SoC FPGA board. It integrates a VGA display for output and a PS2 keyboard for input, delivering a retro gaming experience with modern hardware design techniques. Through efficient use of finite state machines, a pseudo-random number generator for dynamic gameplay, and on-chip RAM for state management, the game aims to provide an engaging and smooth user experience.

## Features
* **Dynamic VGA Display:** Achieved through single buffering for seamless visual output.
* **Real-time PS2 Keyboard Input:** For intuitive and responsive control of the snake.
* **Efficient Game Logic Management:** Utilizing two finite state machines for a streamlined gameplay experience.
* **Pseudo-random Number Generator:** To randomize game elements, enhancing the challenge.
* **On-Chip RAM Storage:** For quick retrieval and storage of game states and images, ensuring continuity and a smooth user experience.

## Files Description
* **snake_game.sv:** The main game module that integrates all components.
* **snake.sv:** Manages the snake's logic, including movement and growth.
* **rate_divider.v, memory_counter.v, keyboard_input.v, hex_decoder.v, counter.v:** Supporting modules for timing, memory management, input processing, and display logic.
* **vga.sv:** A stub for the VGA output logic, illustrating the required interface.

##  Hardware Requirements
* DE1-SoC FPGA Board
* VGA-compatible monitor
* PS/2 Keyboard

## Setup and Deployment
1. **Hardware Setup:** Connect your VGA monitor and PS/2 keyboard to the FPGA board.
2. **VGA and PS2 Adapters:** Locate and integrate compatible VGA and PS2 adapters. These can be found through online repositories or FPGA communities.
3. **Compilation and Programming:** Compile the project in your FPGA development environment and upload it to the DE1-SoC board following standard procedures.

## Gameplay
Navigate the snake to consume food, grow in length, and avoid collisions. The game leverages keyboard inputs for direction control and employs a scoring system based on food consumption.
