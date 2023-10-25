const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const {anyValue} = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const {expect} = require("chai");

const {ethers} = require("hardhat")

describe("Lottery", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployOneYearLockFixture() {
        const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
        const ONE_GWEI = 1_000_000_000;

        const lockedAmount = ONE_GWEI;
        const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const Lock = await ethers.getContractFactory("Lock");
        const lock = await Lock.deploy(unlockTime, {value: lockedAmount});

        return {lock, unlockTime, lockedAmount, owner, otherAccount};
    }

    async function deployLottery() {
        const Lottery = await ethers.getContractFactory("Lottery")
        const lottery = await Lottery.deploy()
        return {lottery};
    }

    describe("Lottery", function () {
        it("Should be deployed", async function () {
            const {lottery} = await loadFixture(deployLottery)
            const [owner, p1, p2, p3] = await ethers.getSigners();

            await expect(await lottery.totalParticipants()).to.equal(0);
            await expect(lottery.connect(p1).register()).to.be.revertedWith("bid must be greater than 0")
        }).timeout(5000)

        it("Lottery play", async function () {
            const [owner, p1, p2, p3] = await ethers.getSigners();
            const {lottery} = await loadFixture(deployLottery)

            await lottery.connect(p1).register({value: ethers.parseEther("1")})
            await expect(await lottery.totalParticipants()).to.equal(1);
            await lottery.connect(p2).register({value: ethers.parseEther("2")})
            await lottery.connect(p3).register({value: ethers.parseEther("3")})
            await expect(await lottery.totalParticipants()).to.equal(3);

            await lottery.draw()
            await expect(await lottery.finished()).to.be.true;

        })


    })

});
