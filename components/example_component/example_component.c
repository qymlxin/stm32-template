#include "example_component.h"
#include "example_lib.h"

uint32_t example_component_run(uint32_t value)
{
    return example_lib_increment(value);
}
