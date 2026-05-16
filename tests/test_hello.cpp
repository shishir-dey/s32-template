/*
 * NXP S32 Firmware Template
 * File: tests/test_hello.cpp
 * Description: Sample unit test
 * Author: Shishir Dey
 * License: MIT
 */

#include <gtest/gtest.h>

/**
 * @brief Sample smoke test - verifies the test framework is wired up correctly.
 *
 * Replace / extend this with real unit tests for your firmware modules.
 */
TEST(HelloWorld, BasicAssertion)
{
    EXPECT_EQ(1 + 1, 2);
}

TEST(HelloWorld, StringComparison)
{
    std::string project = "s32_template";
    EXPECT_EQ(project, "s32_template");
}
