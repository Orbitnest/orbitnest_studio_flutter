# OrbitNest Flutter Package - Claude Development Reference

## Overview

This document serves as a reference guide for Claude AI to implement the OrbitNest Flutter package. The package is designed as a drop-in replacement for Supabase, using the BLoC pattern for state management.

## Key Requirements
- **No UI Components**: Focus only on business logic and API interaction methods
- **BLoC Pattern**: All state management must use flutter_bloc
- **Supabase Compatibility**: Drop-in replacement with identical APIs
- **API Endpoint Coverage**: Complete implementation of all OrbitNest Studio endpoints
- **Type Safety**: Full null-safety with Freezed models

## Essential Documentation References

### Primary Implementation Documents
- **API Guide**: `/docs/00_api_guide.md` - Complete API endpoint documentation with curl examples
- **Implementation Guide**: `/docs/01_package_implementation.md` - Detailed package structure and implementation details  
- **Implementation Plan**: `/docs/IMPLEMENTATION_PLAN.md` - Complete 13-week development roadmap with code examples, dependencies, and testing strategy

### Development Instructions
**CRITICAL**: Always read and follow the detailed instructions, code examples, and implementation patterns provided in the above documentation files. These files contain:
- Complete project structure
- Detailed code examples for each module
- API endpoint mappings
- Dependencies and configuration
- Phase-by-phase implementation guide
- Testing strategies
- All architectural decisions and patterns

## Quick Start Instructions for Claude

1. **Start with the Implementation Plan**: Read `/docs/IMPLEMENTATION_PLAN.md` for the complete 13-week development roadmap
2. **Reference API Documentation**: Use `/docs/00_api_guide.md` for all API endpoint specifications
3. **Follow Implementation Patterns**: Use `/docs/01_package_implementation.md` for detailed code structure and examples
4. **Phase-by-Phase Development**: Follow the phases outlined in the implementation plan exactly
5. **Code Generation Setup**: Ensure proper freezed and json_serializable configuration as specified in the plan

## Development Workflow

When implementing any feature:
1. Consult the implementation plan for the specific phase requirements
2. Review the API guide for endpoint specifications
3. Follow the code patterns and architecture from the implementation guide
4. Create tests as outlined in the testing strategy
5. Ensure Supabase compatibility as specified

**Remember**: All detailed code examples, dependencies, project structure, and implementation guidance are in the referenced documentation files. Use this reference file only for quick orientation and always defer to the comprehensive documentation for actual implementation details.

