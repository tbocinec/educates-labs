# Demonstrates ENTRYPOINT + CMD combination
# ENTRYPOINT defines a fixed executable that cannot be easily overridden.
# CMD provides default arguments — the user can override only the CMD part.
#
# When this container runs:
#   docker run ep-test           → executes: python -c "print(42)"
#   docker run ep-test "print(7)" → executes: python -c "print(7)"

FROM python:3.12-slim

ENTRYPOINT ["python", "-c"]
CMD ["print(42)"]
