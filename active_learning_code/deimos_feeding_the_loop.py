{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "eab836bf",
   "metadata": {},
   "outputs": [],
   "source": [
    "import subprocess\n",
    "import os\n",
    "\n",
    "def run_maple():\n",
    "    # Run the bash script\n",
    "    subprocess.run([\"./phyloracle.sh\"], check=True)\n",
    "\n",
    "def active_learning_loop(num_iterations):\n",
    "    for i in range(num_iterations):\n",
    "        print(f\"Iteration {i+1}\")\n",
    "        \n",
    "        # Run MAPLE to produce phylogenetic tree\n",
    "        run_maple()\n",
    "        \n",
    "        # Process the output file\n",
    "        output_file = f\"output_result_{i+1}.tree\"\n",
    "        # Add your code here to process the output file (e.g., extract labeled samples)\n",
    "\n",
    "        # Example: Move the output file to a new directory\n",
    "        new_directory = \"labeled_samples\"\n",
    "        os.makedirs(new_directory, exist_ok=True)\n",
    "        os.rename(output_file, os.path.join(new_directory, output_file))\n",
    "\n",
    "# Example usage\n",
    "active_learning_loop(num_iterations=5)\n"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3 (ipykernel)",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.11.5"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
