fs:
	nvcc -arch=sm_30 main.cu -o fs
debug:
	nvcc -arch=sm_30 main.cu -g -G -o fs-debug
clean:
	rm fs fs-debug
