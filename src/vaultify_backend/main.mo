import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Time "mo:base/Time";
import Float "mo:base/Float";
import List "mo:base/List";
import Text "mo:base/Text";
import Array "mo:base/Array";

// Wallet System
//=> De
actor vaulTify {
  stable var currentValue: Float = 300;

  stable var startTime = Time.now();
  startTime := Time.now();
  Debug.print(debug_show(startTime));

  // Transaction fee (e.g., 0.5% of the transaction amount)
  let transactionFeeRate: Float = 0.005;
  Debug.print(debug_show(transactionFeeRate));

  // New variable for adjustable interest rate
  stable var interestRate: Float = 1.01;

  // New stable variable to keep track of the total number of transactions
  stable var transactionCount: Nat = 0;

  // New stable variable to track total fees collected
  stable var totalFeesCollected: Float = 0.0;

  // New stable variable to keep track of total rewards given
  stable var totalRewards: Float = 0.0;

  // New stable variable to track the last bonus claim time
  stable var lastBonusClaimTime: Time.Time = 0;

  // New stable variable to keep track of locked funds
stable var lockedFunds: Float = 0.0;

// New stable variable to track the lock period end time
stable var lockEndTime: Time.Time = 0;

  // Allow users to deposit an amount
  public func deposit(amount: Float) {
    currentValue += amount;
    transactionCount += 1;  // Increment the transaction count   
    Debug.print(debug_show(currentValue));
  };

  // Allow users to withdraw an amount from the currentValue
  // by decreasing the currentValue amount
  public func withdraw(amount: Float) {
    let fee: Float = amount * transactionFeeRate;
    let totalAmount: Float = amount + fee;
    let tempValue: Float = currentValue - totalAmount;

    if (tempValue >= 0) {
      currentValue -= totalAmount;
      transactionCount += 1;  // Increment the transaction count
      Debug.print(debug_show(currentValue));
    } else {
      Debug.print("Insufficient funds")
    }
  };

  public query func checkBalance(): async Float {
    return currentValue;
  };

  // TPSR => Time-based Profit Sharing Rate
  // timeElapsedNS in Nano-seconds
  // timeElapsedS in seconds
  // Compound interest that gives interest per second
  public func compoundInterest() {
    let currentTime = Time.now();
    let timeElapsedNS = currentTime - startTime;
    let timeElapsedS = timeElapsedNS / 1000000000;
    currentValue := currentValue * (1.01 ** Float.fromInt(timeElapsedS));
  };

  // New function to set the interest rate
  public func setInterestRate(newRate: Float) {
    interestRate := newRate;
    Debug.print("Interest rate updated to " # debug_show(newRate));
  };

   // New function to simulate wallet connection
  public func connectToWallet(walletType: Text) {
    // Placeholder for actual wallet connection logic
    Debug.print("Connecting to " # walletType # " wallet...");
    // Simulate connection success
    Debug.print(walletType # " wallet connected successfully!");
  };

  // New function to simulate connection to Plug wallet
  public func connectToPlugWallet() {
    // Placeholder for actual Plug wallet connection logic
    Debug.print("Connecting to Plug wallet...");
    // Simulate connection success
    Debug.print("Plug wallet connected successfully!");
  };

  // New function to get the total number of transactions
  public query func getTransactionCount(): async Nat {
    return transactionCount;
  };

  // New function to get the total fees collected
  public query func getTotalFeesCollected(): async Float {
    return totalFeesCollected;
  };

  // New function to calculate and distribute rewards
  public func distributeRewards() {
    let reward: Float = currentValue * 0.0075; // Example: 0.75% of the current value as a reward
    currentValue += reward;
    totalRewards += reward;
    Debug.print("Reward distributed: " # debug_show(reward));
    Debug.print("Total rewards: " # debug_show(totalRewards));
  };

  // New function to get the total rewards given
  public query func getTotalRewards(): async Float {
    return totalRewards;
  };

  // New function to claim daily bonus
  public func claimDailyBonus() {
    let currentTime = Time.now();
    let timeElapsedS = (currentTime - lastBonusClaimTime) / 1000000000;

    if (timeElapsedS >= 86400) {  // 86400 seconds = 24 hours
      let bonus: Float = 2.0;  // Fixed bonus amount
      currentValue += bonus;
      lastBonusClaimTime := currentTime;  // Update the last bonus claim time
      Debug.print("Daily bonus claimed: " # debug_show(bonus));
      Debug.print("New balance: " # debug_show(currentValue));
    } else {
      Debug.print("Bonus already claimed. Please wait for 24 hours.");
    }
  };

  // Function to lock a portion of the funds for a specified number of minutes
  public func lockFunds(amount: Float, lockPeriod: Nat) {
    if (amount <= currentValue) {
      lockedFunds += amount;
      currentValue -= amount;
      lockEndTime := Time.now() + (lockPeriod * 60 * 1000000000); // lockPeriod is in minutes, converting to nanoseconds
      Debug.print("Funds locked: " # debug_show(amount));
      Debug.print("Locked funds will be available after: " # debug_show(lockPeriod) # " minutes.");
    } else {
      Debug.print("Insufficient funds to lock");
    }
  };

  // Function to unlock funds after the lock period has ended
  public func unlockFunds() {
    let currentTime = Time.now();
    if (currentTime >= lockEndTime) {
      currentValue += lockedFunds;
      Debug.print("Locked funds have been unlocked: " # debug_show(lockedFunds));
      lockedFunds := 0.0;  // Reset locked funds
    } else {
      Debug.print("Funds are still locked. Please wait until the lock period ends.");
    }
  };

  // Query function to check locked funds
  public query func checkLockedFunds(): async Float {
    return lockedFunds;
  };

}
