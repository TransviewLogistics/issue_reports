#!/bin/sh
rm $(find . -type f -name 'issue_reports-*.gem')
gem build
gem push $(find . -type f -name 'issue_reports-*.gem' | sort | tail -n1)
