make compile TESTTYPE=UVM
make xsim TESTTYPE=UVM TESTNAME=base_test               | tee >(grep -E "TEST PASSED|TEST FAILED" >> build/test_status.txt)
make xsim TESTTYPE=UVM TESTNAME=even_parity_check_test  | tee >(grep -E "TEST PASSED|TEST FAILED" >> build/test_status.txt) 
make xsim TESTTYPE=UVM TESTNAME=odd_parity_check_test   | tee >(grep -E "TEST PASSED|TEST FAILED" >> build/test_status.txt)
cat build/test_status.txt
echo -n "PASSED: " && grep -c "PASSED" build/test_status.txt
echo -n "FAILED: " && grep -c "FAILED" build/test_status.txt