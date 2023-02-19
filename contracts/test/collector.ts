import type { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import chai, { expect } from 'chai';
import { solidity } from '@nomicfoundation/hardhat-chai-matchers'; 
import { ethers } from 'hardhat';
import type { FreeObject } from "./utils/FreeTree";
import FreeTree from "./utils/FreeTree";
import type { Collector } from './typechain-types';
import type { uwuSplitter } from './typechain-types';

chai.use(solidity);

describe('NFT Sale Test', () => {
	let signers: SignerWithAddress[];
	let primary: SignerWithAddress;
	let alice: SignerWithAddress;
	let bob: SignerWithAddress;
	let collector: Collector;
	let splitter: uwuSplitter;
	let addressTree: FreeTree;

	/// deploy 3 splitters, with different amount of ETHs, then deploy the collector and test.


    // let's make bob's amount 2 and alice's 1
	before('Setup', async () => {
		signers = await ethers.getSigners();
		[primary, alice, bob] = signers;

    const addresses: FreeObject[] = [];
        
        addresses.push({
        account: bob.address,
        amount: 2
        
    });
        addresses.push({
        account: alice.address,
        amount: 548
    });
    // we will see how to push multiple ones later

	addressTree = new FreeTree(addresses);

	const SSplitter = await ethers.getContractFactory('uwuSplitter');
	splitter = (await SSplitter.deploy()) as uwuSplitter;
	await splitter.deployed();

	const CCollector = await ethers.getContractFactory('Collector');
	collector = (await CCollector.deploy()) as Collector;
	await collector.deployed();
	
	});

	// //////////////////////////
	// NFT Testing            //
	// //////////////////////////

	it('Should properly recognize the owner', async () => {
        expect(await collector.owner()).to.equal(primary.address);
    });

	it('Should  let owner add contract', async () => {
		await collector.connect(primary.address).addContract(splitter.address);
	});

	
});