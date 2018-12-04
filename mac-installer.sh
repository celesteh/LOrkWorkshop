#!/bin/bash

if [ ! -d "$HOME/Library/Application Support/SuperCollider" ]; then
  mkdir ~/Library/Application\ Support/SuperCollider
fi

if [ ! -d "$HOME/Library/Application Support/SuperCollider/Extensions" ]; then
  mkdir ~/Library/Application\ Support/SuperCollider/Extensions
fi

if [ ! -d "$HOME/Library/Application Support/SuperCollider/Extensions/lork" ]; then
  mv ./lork ~/Library/Application\ Support/SuperCollider/Extensions/
fi

echo "Done!"
