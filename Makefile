.PHONY: status break fix reset

status:
	@git status --short
	@kubectl get applications -n argocd
	@kubectl get pods -n buildin10

break:
	@git pull --ff-only
	@grep -q 'value: "8080"' apps/payments-api/deployment.yaml
	@sed -i 's/value: "8080"/value: "70000"/' apps/payments-api/deployment.yaml
	@git add apps/payments-api/deployment.yaml
	@git commit -m "demo: break payments-api with invalid PORT"
	@git push origin main

fix:
	@git pull --ff-only
	@test "$$(git log -1 --format=%s)" = "demo: break payments-api with invalid PORT" || (echo "HEAD is not the demo break commit"; exit 1)
	@git revert --no-edit HEAD
	@git push origin main

reset:
	@git pull --ff-only
	@cp recording/baseline/payments-api-deployment.yaml apps/payments-api/deployment.yaml
	@if ! git diff --quiet -- apps/payments-api/deployment.yaml; then git add apps/payments-api/deployment.yaml && git commit -m "demo: reset payments-api configuration" && git push origin main; else echo "Payments API already at baseline"; fi
