#!/bin/bash
set -euo pipefail

elephant service enable
systemctl --user enable --now elephant.service