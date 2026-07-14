set cov_db_names [list]

foreach arg $argv {
    lappend cov_db_names "-cov_db_name" $arg
}

exec xcrg {*}$cov_db_names \
          -cov_db_dir ./cov_db \
          -report_format html \
          -report_dir coverage_report \

exit