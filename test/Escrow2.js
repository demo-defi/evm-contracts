const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const {anyValue} = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const {expect} = require("chai");

const {ethers} = require("hardhat")

describe("Escrow", function () {

    async function deployEscrow() {
        const Escrow = await ethers.getContractFactory("Escrow2")
        const escrow = await Escrow.deploy()
        return {escrow};
    }

    describe("Escrow", function () {
        it("Should be deployed", async function () {
            const {escrow} = await loadFixture(deployEscrow)
            const [owner, p1, p2, p3] = await ethers.getSigners();

            await expect(await escrow.totalCurrencies()).to.equal(0);
        }).timeout(5000)

        it("Escrow play", async function () {
            const [owner, p1, p2, p3] = await ethers.getSigners();
            const {lottery} = await loadFixture(deployEscrow)

            await lottery.deposit()
            await expect(await lottery.totalParticipants()).to.equal(1);
            await lottery.connect(p2).register({value: ethers.parseEther("2")})
            await lottery.connect(p3).register({value: ethers.parseEther("3")})
            await expect(await lottery.totalParticipants()).to.equal(3);

            await lottery.draw()
            await expect(await lottery.finished()).to.be.true;

        })


    })

});
