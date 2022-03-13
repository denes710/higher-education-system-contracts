// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Common {
    enum EState { offSeason, applying, active }

    struct State
    {
        EState _state;
    }

    function current(State storage state) internal view returns (EState) {
        return state._state;
    }

    function nextState(State storage state) internal {
        if (state._state == EState.offSeason) {
            state._state = EState.applying;  
        } else if (state._state == EState.applying) {
            state._state = EState.active;
        } else if (state._state == EState.active) {
            state._state = EState.offSeason;
        } else {
            init(state);
        }
    }

    function init(State storage state) internal {
        state._state = EState.offSeason;
    }
}