import { useState } from "react";
import { ethers } from "ethers";

const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

const abi = [
  "function execute(address to,uint256 value,bytes data,bytes[] signatures)"
];

export default function App() {

  const [provider,setProvider] = useState();
  const [signer,setSigner] = useState();
  const [contract,setContract] = useState();

  async function connect(){
    const prov = new ethers.BrowserProvider(window.ethereum);
    await prov.send("eth_requestAccounts",[]);

    const sign = await prov.getSigner();

    const cont = new ethers.Contract(contractAddress,abi,sign);
    console.log(await sign.getAddress())
    setProvider(prov);
    setSigner(sign);
    setContract(cont);
  }

  async function execute(){

    const to = prompt("Destination address");
    const value = ethers.parseEther(prompt("ETH amount"));
    const data = "0x";

    const tx = await contract.execute(to,value,data,[]);
    await tx.wait();
  }

  return (
    <div style={{padding:40}}>

      <h2>MultiSig Wallet</h2>

      <button onClick={connect}>Connect Wallet</button>

      <br/><br/>

      <button onClick={execute}>Execute Transaction</button>

    </div>
  );
}
