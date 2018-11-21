// Dependencies
import React, { Component } from 'react';
import Web3 from 'web3';

import logo from './logo.svg';
import './App.css';

// Contract
import randomSwap from './randomSwap';

const web3 = new Web3(window.web3.currentProvider);

class App extends Component {
  state = {
    randonNumber: "N/A",
    bonus: "N/A",
    address: "N/A", 
    symbol: "N/A"
  }
  
  async componentDidMount() {
    // watch game progress changes
    randomSwap.events.allEvents({fromBlock: `0`, toBlock: "latest"}, async (error, result) => {
      if(!error) {
        console.log('result', result);
        if (result.event === "LogRandomNumber") {
          this.setState({
            randonNumber: result.returnValues[0]
          });
          
        }

        if(result.event === "LogLastPlayerAddress") {
          this.setState({ address: result.returnValues[0] })
        }
        
        if(result.event === "LogSymbol") {
          this.setState({ symbol: result.returnValues[0]})
        }
        
        if (result.event === "LogResultWithBonus") {
          this.setState({ bonus: result.returnValues[0] })
        }
      } else {
        console.log('err', error)
      }
    });

  }

  render() {
    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <p>
            Edit <code>src/App.js</code> and save to reload.
          </p>
          <p>
            Current Random Number: {this.state.randonNumber}
          </p>
          <p>
            Random Number w/ Bonus: {this.state.bonus}
          </p>
          <p>
            Last Player Address: {this.state.address}
          </p>
          <p>
            Token Won: {this.state.symbol}
          </p>
          <a
            className="App-link"
            href="https://reactjs.org"
            target="_blank"
            rel="noopener noreferrer"
          >
            Learn React
          </a>
        </header>
      </div>
    );
  }
}

export default App;
