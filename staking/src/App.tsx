import { useState } from "react";
import { ethers } from "ethers";

const contractAddress = "0x0165878A594ca255338adfa4d48449f69242Eb8F";

const abi = [
  "function stake(uint256)",
  "function withdraw(uint256)",
  "function claim()"
];

function App() {
  const [provider, setProvider] = useState<ethers.BrowserProvider | null>(null);
  const [signer, setSigner] = useState<ethers.JsonRpcSigner | null>(null);
  const [contract, setContract] = useState<ethers.Contract | null>(null);
  const [amount, setAmount] = useState<string>("");
 const  [account,setAccount] = useState<string>("")
  // Connect Wallet
  const connect = async () => {    

    if (!window.ethereum) {
      alert("Please install MetaMask");
     return;
    }

    const _provider = new ethers.BrowserProvider(window.ethereum);
    await _provider.send("eth_requestAccounts", []);
    const signer = await _provider.getSigner();

    const contract = new ethers.Contract(contractAddress, abi, signer);

    setProvider(_provider);
    setSigner(signer);
    setContract(contract);
    setAccount(await signer.getAddress())
  };

  // Stake
  const stake = async () => {
    if (!contract || !amount) return;
   try{
    const tx = await contract.stake(
      ethers.parseUnits(amount, 18)
    );
    await tx.wait();
    alert("Staked successfully");
   }catch(err){
       console.log(err)
   }
  };

  // Withdraw
  const withdraw = async () => {
    if (!contract || !amount) return;

    const tx = await contract.withdraw(
      ethers.parseUnits(amount, 18)
    );
    await tx.wait();
    alert("Withdraw successful");
  };

  // Claim
  const claim = async () => {
    if (!contract) return;

    const tx = await contract.claim();
    await tx.wait();
    alert("Rewards claimed");
  };

  return (
    <div style={{ padding: "40px", fontFamily: "Arial" }}>
      <h2>Staking DApp</h2>

      <button onClick={connect}>{account ? account.substr(0,7) : "Connect Wallet"}</button>

      <br /><br />

      <input
        type="text"
        placeholder="Amount to stake"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
      />

      <br /><br />

      <button onClick={stake}>Stake</button>
      <button onClick={withdraw} style={{ marginLeft: "10px" }}>
        Withdraw
      </button>
      <button onClick={claim} style={{ marginLeft: "10px" }}>
        Claim
      </button>
    </div>
  );
}

export default App;
