// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Common {
    enum EState {
        offSeason,
        planning,
        applying,
        trading,
        active
    }

    struct State {
        EState state;
    }

    function current(State storage state_) internal view returns (EState) {
        return state_.state;
    }

    function nextState(State storage state_) internal {
        if (state_.state == EState.offSeason) {
            state_.state = EState.planning;
        } else if (state_.state == EState.planning) {
            state_.state = EState.applying;
        } else if (state_.state == EState.applying) {
            state_.state = EState.trading;
        } else if (state_.state == EState.trading) {
            state_.state = EState.active;
        } else if (state_.state == EState.active) {
            state_.state = EState.offSeason;
        } else {
            init(state_);
        }
    }

    function init(State storage state_) internal {
        state_.state = EState.offSeason;
    }
}