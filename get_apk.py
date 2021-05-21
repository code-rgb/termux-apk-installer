import asyncio
import json
import os
import sys
from typing import Dict, List, Optional

import aiohttp


class FetchApk:
    def __init__(self, session: aiohttp.ClientSession):
        self._session = session

    async def _get_json(self, url: str) -> Optional[Dict]:
        async with self._session.get(url) as resp:
            if resp.status == 200:
                try:
                    return await resp.json()
                except aiohttp.client_exceptions.ContentTypeError:
                    return json.loads(await resp.text())

    async def github(self, repo: str, name: str) -> Optional[str]:
        for apk in (
            await self._get_json(f"https://api.github.com/repos/{repo}/releases/latest")
        ).get("assets"):
            if apk.get("name") == name:
                return apk.get("browser_download_url")

    async def fdroid(self, pkg_name: str) -> Optional[str]:
        version = (
            await self._get_json(f"https://f-droid.org/api/v1/packages/{pkg_name}")
        ).get("suggestedVersionCode")
        return f"https://f-droid.org/repo/{pkg_name}_{version}.apk"


def promt(title: str, info: str) -> bool:
    answer = input(
        f"\n • {title} ({info})\n  Q. Do you want to install {title} ?\n  (y/n) : "
    ).lower()
    if answer in ("yes", "y"):
        print("  [+]  added", title)
        return True
    if answer in ("no", "n"):
        print("  [-]  skipped", title)
    else:
        print("  [x]  invalid input ! skipping ...")
    return False


async def write_choice(session: aiohttp.ClientSession):
    apkdl = FetchApk(session)

    async def get_downloadlink(x):
        source = x["source"]
        if source == "github":
            return await apkdl.github(*x["args"])
        if source == "fdroid":
            return await apkdl.fdroid(x["package"])
        if source == "json":
            return (await apkdl._get_json(x["api"])).get(x["args"][0])
        if source == "direct":
            return x["link"]
        if source == "gcam":
            return x["link"]

    with open("apps.json", "r") as f:
        data = json.load(f)
    apk_data = data["apps"]
    process = await asyncio.create_subprocess_exec(
        *["getprop", "ro.product.model"],
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    if out := await process.communicate():
        if out[0].decode("utf-8", "replace").strip() == "Redmi Note 8 Pro":
            apk_data.append(data["gcam"]["begonia"])
    choice = input(f"\n\nQuick Install {len(apk_data)} Apps ? (y/n)  ").lower().strip()
    if choice in ("yes", "y"):
        to_install = apk_data
    elif choice in ("no", "n"):
        to_install: List[Dict[str, str]] = []
        for u in apk_data:
            if promt(u["name"], u["description"]):
                to_install.append(u)
    else:
        sys.exit("Invalid response ! Exiting ...")
    urls = await asyncio.gather(*list(map(lambda x: get_downloadlink(x), to_install)))
    with open("apk_urls.txt", "w") as outfile:
        outfile.write("\n".join(urls))


async def main():
    session = aiohttp.ClientSession()
    try:
        await write_choice(session)
    finally:
        await session.close()


if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())
