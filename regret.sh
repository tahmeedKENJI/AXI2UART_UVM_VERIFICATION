make compile TESTTYPE=UVM
make xsim TESTTYPE=UVM TESTNAME=base_test               | tee >(grep -E "TEST PASSED|TEST FAILED" >> build/test_status.txt)
make xsim TESTTYPE=UVM TESTNAME=parity_check_test       | tee >(grep -E "TEST PASSED|TEST FAILED" >> build/test_status.txt) 
make xsim TESTTYPE=UVM TESTNAME=stopbit_check_test      | tee >(grep -E "TEST PASSED|TEST FAILED" >> build/test_status.txt)
make xsim TESTTYPE=UVM TESTNAME=axi2tx_test             | tee >(grep -E "TEST PASSED|TEST FAILED" >> build/test_status.txt)
make xsim TESTTYPE=UVM TESTNAME=rx2axi_test             | tee >(grep -E "TEST PASSED|TEST FAILED" >> build/test_status.txt)
cat build/test_status.txt
echo -n "PASSED: " && grep -c "PASSED" build/test_status.txt
echo -n "FAILED: " && grep -c "FAILED" build/test_status.txt