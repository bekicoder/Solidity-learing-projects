import {ethers} from "ethers"
import {useState,useEffect} from "react"
export default function Test() {
    const CONTRACT_ADDRESS = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0"
    const ABI = [
        "function increment()",
        "function getCount() view returns(uint256)"
    ]
    const [account,setAccount] = useState<string>("")
    const [provider,setProvider] = useState<ethers.windowProvider | null>(null)
    const [signer,setSigner] = useState<ethers.JsonRpcSigner | null>(null)
    const [contract,setContract] = useState<ethers.Contract>(null)
    const [count,setCount] = useState<string>()

    const connectWallet = async()=>{
        if(!window.ethereum){
            return alert("Install metamask")
        }
        const _provider = new ethers.BrowserProvider(window.ethereum)
        await _provider.send("eth_requestAccounts",[])
        const _signer = await _provider.getSigner()
        const _contract = new ethers.Contract(CONTRACT_ADDRESS,ABI,_signer)

        setProvider(_provider)
        setSigner(_signer)
        setContract(_contract)
        setAccount(await _signer.getAddress())
    }

    const increment = async()=>{
        if(contract){
        const increase = await contract.increment()
        await increase.wait()
        console.log("successfull")
        }
    }
    const getCount = async()=>{
        if(contract){
            const count = await contract.getCount()
            console.log(Number(count))
        }
    }
  return (
    <div>
    <div>
    <p>{account}</p>
    <button onClick={connectWallet}>Connect</button>
    <p></p>
    <button onClick={increment}>Incremment</button>
    <button onClick={getCount}>Get</button>
    </div>
    </div>
  )
}

