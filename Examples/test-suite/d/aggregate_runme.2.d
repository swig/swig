module aggregate_runme;

import aggregate.aggregate;

void main() {
  // Confirm that move() returns correct results under normal use.
  int result = move(UP);
  if (result != UP) throw new Exception("UP failed");

  result = move(DOWN);
  if (result != DOWN) throw new Exception("DOWN failed");

  result = move(LEFT);
  if (result != LEFT) throw new Exception("LEFT failed");

  result = move(RIGHT);
  if (result != RIGHT) throw new Exception("RIGHT failed");

  // Confirm that move() raises an exception when the contract is violated.
  try {
    move(0);
    throw new Exception("0 test failed");
  }
  catch (Exception e) {}
}
