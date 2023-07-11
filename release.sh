#!/bin/sh
rm $(find . -type f -name 'issue-reports-*.gem')
gem build
gem push $(find . -type f -name 'issue-reports-*.gem' | sort | tail -n1)
