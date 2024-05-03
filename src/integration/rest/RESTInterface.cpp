/*
 * This file is part of KnowRob, please consult
 * https://github.com/knowrob/knowrob for license details.
 */


int main(int argc, char **argv) {
	InitKnowledgeBase(argc, argv);
	int status;
	try {
		status = run(argc, argv);
	}
	catch (std::exception &e) {
		KB_ERROR("a '{}' exception occurred in main loop: {}.", typeid(e).name(), e.what());
		status = EXIT_FAILURE;
	}
	ShutdownKnowledgeBase();
	return status;
}
