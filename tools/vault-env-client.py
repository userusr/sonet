#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys


def main():
    if os.environ.get('ANSIBLE_VAULT_PASSWORD') is None:
        sys.exit(1)
    else:
        print(os.environ.get('ANSIBLE_VAULT_PASSWORD'))
        sys.exit(0)


if __name__ == '__main__':
    main()
