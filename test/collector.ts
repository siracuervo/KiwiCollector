import type { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import chai, { expect } from 'chai';
import '@nomicfoundation/hardhat-chai-matchers'; 
import { ethers } from 'hardhat';
import type { FreeObject } from "./utils/FreeTree";
import FreeTree from "./utils/FreeTree";
import type { CollectorTest } from './typechain-types';
import type { uwuSplitter } from './typechain-types';
import type { uwuSplitter2 } from './typechain-types';

describe('NFT Sale Test', () => {
	let signers: SignerWithAddress[];
	let primary: SignerWithAddress;
	let alice: SignerWithAddress;
	let bob: SignerWithAddress;
	let collector: CollectorTest;
	let splitter: uwuSplitter;
	let splitter2: uwuSplitter2;
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

	const SSplitter2 = await ethers.getContractFactory('uwuSplitter2');
	splitter2 = (await SSplitter2.deploy()) as uwuSplitter2;
	await splitter2.deployed();

	const CCollector = await ethers.getContractFactory('CollectorTest');
	collector = (await CCollector.deploy()) as CollectorTest;
	await collector.deployed();
	
	});

	// //////////////////////////
	// NFT Testing            //
	// //////////////////////////

	it('Should properly recognize the owner', async () => {
        expect(await collector.owner()).to.equal(primary.address);
    });

	it('cant collect if there are no contracts added', async () => {
		await expect(collector.connect(bob).collectAllETH()).to.be.reverted;
	});

	it('Should  let owner add contract', async () => {
		await collector.connect(primary).addContract(splitter.address);
	});

	it('Should  let owner add contract', async () => {
		await collector.connect(primary).addContract(splitter2.address);
	});

	it('Should not let add duplicate', async () => {
		await expect(collector.connect(primary).addContract(splitter2.address)).to.be.reverted;
	});

	it('Should not let anybody remove a contract', async () => {
		await expect(collector.connect(bob).removeContract(splitter2.address)).to.be.reverted;
	});

	it('Should list two splitters', async () => {
		await collector.connect(primary).listContracts();
	});

	it('splitterCount should be two', async () => {
		expect(await collector.splitterCount()).to.equal(2);
	});

	it('Should not let updatebyindex with a address that already exists', async () => {
		await expect(collector.connect(primary).updateAtIndex(0, splitter2.address)).to.be.reverted;
	});

	it('wasETHorWETH on any splitter should be 0 since it was not called yet', async () => {
		expect(await splitter2.wasETHorWETH()).to.equal(0);
	});

	it('Should  let Bob (anybody) collect the ETH', async () => {
		await collector.connect(bob).collectAllETH();
	});

	it('wasETHorWETH should be 1 since last call was ETH', async () => {
		expect(await splitter.wasETHorWETH()).to.equal(1);
	});

	it('times called should be two', async () => {
		expect(await collector.howManyTimes()).to.equal(2);
	});

	it('Should  let Bob (anybody) collect the WETH', async () => {
		await collector.connect(bob).collectAllWETH();
	});

	it('wasETHorWETH should be 2 since last call was WETH', async () => {
		expect(await splitter.wasETHorWETH()).to.equal(2);
	});

	it('Should let updatebyindex work with an address that does not exist', async () => {
		await collector.connect(primary).updateAtIndex(1,alice.address);
	});
	
	it('see if updateByIndex works', async () => {
		expect(await collector.connect(primary).getAddressByIndex(1)).to.equal(alice.address);
	});	

	it('wasETHorWETH on second splitter should be 2 since last call was WETH', async () => {
		expect(await splitter2.wasETHorWETH()).to.equal(2);
	});
});