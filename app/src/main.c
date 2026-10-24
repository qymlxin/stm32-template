#include "stm32f10x.h"
#include "example_component.h"
#include "example_third_party.h"

volatile uint32_t counter = 0;

int main(void)
{
    while (1)
    {
        counter = example_component_run(counter);
        counter += example_third_party_value();
    }
}
